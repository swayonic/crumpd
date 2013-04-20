class Sitrack < ActiveRecord::Base
  self.table_name = 'sitrack_tracking' # Needs to know a table name

  establish_connection "sitrack_#{Rails.env}"

  # Updates all periods marked as 'keep_updated'
  def self.update_all
    for p in Period.updated
      update_period p
    end

    for line in regions_query
      if line[:name] and line[:name] =~ /^([A-Z]+)$/
        name = $1
        if !Region.find_by_name(name)
          r = Region.new(:name => name)
          r.save
        end
      end
    end
  end

  # Updates a single period
  def self.update_period(p)
    return false if !p or !p.keep_updated?

    users = Array.new
    users.concat p.admins
    for g in p.groups
      users.concat g.coaches
    end

    for line in users_query(users)
      if !user = process_user(line, p) or !user.save
        logger.info ">>>>> Invalid Data"
        logger.info ">>> GUID: #{line[:guid]}"
        logger.info ">>> Account Number: #{line[:accountNo]}"
        logger.info ">>> Name: #{line[:firstName]} #{line[:lastName]}"
      end
    end

    # With teams, have to deal with missing and conflicting additional data (city, state, country, etc)
    # So, {123 => {:city => [nil, 'Austin', 'AUSTIN'], :state => {...}, ...}, 124 => {...}, ...}
    teams = Hash.new

    for line in period_query(p)
      if user = process_user(line, p) and user.save
        begin
          # Create or update assignment
          assn = Assignment.find_by_period_id_and_user_id(p.id, user.id) || Assignment.new(:period_id => p.id, :user_id => user.id)
          if line[:tenure] and line[:internType]
            assn.intern_type = "#{line[:tenure]} #{line[:internType]}"
          elsif line[:internType]
            assn.intern_type = line[:internType]
          else
            assn.intern_type = nil
          end
          assn.status = line[:status]

          if !assn.active?
            # Don't bother updating the rest of the information
            assn.save!
            next
          end

          # Set assignment team
          if sitrack_id = line[:asgTeam]
            # Find existing team or create one
            if !team = Team.find_by_period_id_and_sitrack_id(p.id, sitrack_id)
              team = Team.new(:period_id => p.id, :sitrack_id => sitrack_id)
              team.save
            end
            assn.team = team

            # Save team data for processing later
            if !teams[sitrack_id]
              teams[sitrack_id] = Hash.new
              teams[sitrack_id][:city] = Array.new
              teams[sitrack_id][:state] = Array.new
              teams[sitrack_id][:country] = Array.new
              teams[sitrack_id][:continent] = Array.new
            end
            teams[sitrack_id][:city] << line[:asgCity]
            teams[sitrack_id][:state] << line[:asgState]
            teams[sitrack_id][:country] << line[:asgCountry]
            teams[sitrack_id][:continent] << line[:asgContinent]
          end

          # Set assignment group
          if name = line[:coachName]
            name = Group.capitalize_name(name)
            if !group = Group.find_by_period_id_and_coach_name(p.id, name)
              group = Group.new(:period_id => p.id, :coach_name => name)
              group.save
            end
            assn.group = group
          end

          assn.save!

          # Create or update goals
          if amt = line[:monthlyGoal]
            goal = assn.goals.find_by_frequency(12) || assn.goals.build(:frequency => 12)
            goal.amount = amt
            goal.save!
          end
          if amt = line[:oneTimeGoal]
            goal = assn.goals.find_by_frequency(0) || assn.goals.build(:frequency => 0)
            goal.amount = amt
            goal.save!
          end

        rescue Exception => e
          logger.info 'ERROR: ' + e.message
        rescue
          logger.info 'ERROR: Unknown exception'
        end
      else
        logger.info ">>>>> Invalid Data"
        logger.info ">>> GUID: #{line[:guid]}"
        logger.info ">>> Account Number: #{line[:accountNo]}"
        logger.info ">>> Name: #{line[:firstName]} #{line[:lastName]}"
      end
    end

    # Process team data
    teams.each do |sitrack_id, hash|
      if team = Team.find_by_period_id_and_sitrack_id(p.id, sitrack_id)
        team.city = process_team_data(hash[:city])
        team.state = process_team_data(hash[:state])
        team.country = process_team_data(hash[:country])
        team.continent = process_team_data(hash[:continent])

        team.save
      end
    end

    # Delete empty teams
    for team in p.teams
      team.destroy if team.assignments.count == 0
    end

    # Update team names
    update_teams(p)

    # Delete empty groups
    for group in p.groups
      group.destroy if group.assignments.count == 0
    end

    p.last_updated = DateTime.now
    return p.save
  end

  # Updates all teams for a period
  # (Called within update_period)
  def self.update_teams p
    for line in teams_query(p.teams)
      if t = Team.find_by_sitrack_id(line[:teamID])
        t.sitrack_name = line[:name] if !line[:name].blank?
        t.save
      end
    end
  end

  # Used to find a user by their account number
  # Returns an unsaved User or nil
  def self.find_user(account_number)
    users = Array.new
    users << User.new(:account_number => User.cleanup_account_number(account_number))
    result = users_query(users)

    if result and result.count == 1
      return process_user(result[0])
    else
      return nil
    end
  end

  ### Queries

  def self.regions_query
    Sitrack.find_by_sql('SELECT caringRegion AS name FROM sitrack_tracking WHERE caringRegion IS NOT NULL GROUP BY name')
  end

  def self.users_query(users)
    account_numbers = Array.new
    guids = Array.new

    for u in users
      if u.guid and !u.guid.blank?
        guids << "'#{u.guid}'"
      elsif u.account_number and !u.account_number.blank?
        account_numbers << "'#{u.account_number}'"
      end
    end

    return Array.new if guids.count == 0 and account_numbers.count == 0

    query ='SELECT ' +
      'ssm.globallyUniqueID as guid, ' +
      'person.accountNo, person.firstName, person.preferredName, person.lastName, address.email, address.cellPhone, address.homePhone, address.workPhone ' +
      'FROM ministry_person AS person ' +
      'LEFT JOIN simplesecuritymanager_user AS ssm ON ssm.userID = person.fk_ssmUserID ' +
      'LEFT JOIN ministry_newaddress AS address ON address.fk_personID = person.personID AND address.addressType = "current" ' +
      'WHERE '

    if account_numbers.count > 0
      query = query + "person.accountNo IN (#{account_numbers.join(',')})"
    end
    if guids.count > 0 and account_numbers.count > 0
      query = query + ' OR '
    end
    if guids.count > 0
      query = query + "ssm.globallyUniqueID IN (#{guids.join(',')})"
    end

    return Sitrack.find_by_sql(query)
  end

  def self.period_query(p)
    Sitrack.find_by_sql('SELECT ' +
      # Fields
      'ssm.globallyUniqueID AS guid, ' +
      'person.accountNo, person.firstName, person.preferredName, person.lastName, ' +
      'address.email, address.cellPhone, address.homePhone, address.workPhone, ' +
      'applies.status, ' +
      'app.applicationID, app.siYear, ' +
      'tracking.caringRegion, tracking.tenure, tracking.internType, tracking.asgTeam, ' +
      'mpd.coachName, mpd.monthlyGoal, mpd.oneTimeGoal ' +
      # Required tables
      'FROM ministry_person AS person ' +
      'JOIN hr_si_applications AS app ON app.fk_personID = person.personID ' +
      'JOIN sitrack_tracking AS tracking ON tracking.application_id = app.applicationID ' +
      # Might not be able to grab these tables, it's OK
      'LEFT JOIN simplesecuritymanager_user AS ssm ON ssm.userID = person.fk_ssmUserID ' +
      'LEFT JOIN ministry_newaddress AS address ON address.fk_personID = person.personID AND address.addressType = "current" ' +
      'LEFT JOIN si_applies AS applies ON applies.id = app.apply_id ' +
      'LEFT JOIN sitrack_mpd AS mpd on mpd.application_id = app.applicationID ' +
      "WHERE app.siYear=#{p.year} AND tracking.caringRegion='#{p.region.name}'"
    )
  end

  # Grabs team names
  def self.teams_query(teams)
    ids = teams.select{|t| !t.sitrack_id.blank? }.map{|t| t.sitrack_id}
    return false if ids.empty?
    Sitrack.find_by_sql(
      'SELECT teamID, name ' +
      'FROM ministry_locallevel ' +
      "WHERE teamID IN(#{ids.join(',')})"
    )
  end

  private

  # Builds a User from a query result
  #   If the User already exists, it returns the original User with updated fields (but not saved)
  def self.process_user(params, period = nil)
    guid = User.cleanup_guid(params[:guid])
    account_number = User.cleanup_account_number(params[:accountNo])

    # Find existing user
    #   by guid
    if guid
      user = User.find_by_guid(guid)
      user.account_number = account_number if user and account_number
    end
    #   or account_number
    if user.nil? and account_number
      user = User.find_by_account_number(account_number)
      user.guid = guid if user and guid
    end
    #   or create a new one
    if user.nil?
      user = User.new if user.nil?
      user.guid = guid
      user.account_number = account_number
    end

    # Update user's params
    user.first_name = params[:firstName]
    user.preferred_name = params[:preferredName]
    user.last_name = params[:lastName]
    user.email = params[:email]
    user.phone = params[:cellPhone] || params[:homePhone] || params[:otherPhone]
    user.time_zone ||= period.region.time_zone if period

    return user
  end

    # Take an array of values and return the best one
    def self.process_team_data(array)
      return nil if array.nil? or array.empty?
      value = nil

      possible_values = Hash.new
      for entry in array
        if entry and entry != 'Unavailable' and entry != 'unavailable' and entry != 'unavail'
          possible_values[entry] = 0 if !possible_values[entry]
          possible_values[entry] = possible_values[entry] + 1
        end
      end

      # Find the mode
      max = 0
      possible_values.each do |entry, frequency|
        if frequency > max
          max = frequency
          value = entry
        end
      end
      return value
    end

end
