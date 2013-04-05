# This class should only be used in development
class Sitrack < ActiveRecord::Base
  self.table_name = 'sitrack_tracking' # Needs to know a table name

  establish_connection "sitrack_#{Rails.env}"

  # Used to find a user by their account number
  # Returns an unsaved User or nil
  def self.find_user(account_number)
    result = Sitrack.find_by_sql(
      'SELECT p.accountNo, p.firstName, p.lastName, p.preferredName, ssm.globallyUniqueID, s.email, s.mobilePhone, s.homePhone, s.otherPhone ' +
      'FROM ministry_person AS p ' +
      'JOIN simplesecuritymanager_user AS ssm ON p.fk_ssmUserID = ssm.userID ' +
      'LEFT JOIN ministry_staff AS s ON p.personID = s.person_id ' +
      "WHERE p.accountNo='#{account_number}'"
      )

    if result and result.count == 1
      r = result[0]
      user = User.find_by_guid(r[:globallyUniqueID]) || User.find_by_account_number(r[:accountNo]) || User.new
      user.guid = r[:globallyUniqueID]
      user.account_number = r[:accountNo]
      user.first_name = r[:firstName]
      user.preferred_name = r[:preferredName]
      user.last_name = r[:lastName]
      user.email = r[:email]
      user.phone = r[:mobilePhone] || r[:homePhone] || r[:otherPhone]
  
      return user
    else
      return nil
    end
  end

  def self.update_period(p)
    return false if !p or !p.keep_updated?

    users = p.admins
    for g in p.groups
      users.concat g.coaches
    end

    users_query(users, p)
    if period_query(p)
      p.last_updated = DateTime.now
      p.save
      return true
    else
      return false
    end
  end

  # Updates all periods marked as 'keep_updated'
  def self.update_all
    users = Array.new
    periods = Array.new

    for p in Period.updated
      update_period p
    end

    regions_query
  end

  private

  def self.regions_query
    result = Sitrack.find_by_sql('SELECT caringRegion FROM sitrack_tracking WHERE caringRegion IS NOT NULL GROUP BY caringRegion').map{|s| s[:caringRegion]}

    if result
      # Process result
      for name in result
        if name and name =~ /^([A-Z]+)$/
          name = $1
          if !Region.find_by_name(name)
            r = Region.new(:name => name)
            r.save
          end
        end
      end
    end
  end

  def self.users_query(users, period = nil)
    account_numbers = Array.new
    guids = Array.new

    for u in users
      if u.guid and !u.guid.blank?
        guids << "'#{u.guid}'"
      elsif u.account_number and !u.account_number.blank?
        account_numbers << "'#{u.account_number}'"
      end
    end

    return false if guids.count == 0 and account_numbers.count == 0

    query = 'SELECT p.accountNo, p.firstName, p.lastName, p.preferredName, ssm.globallyUniqueID, s.email, s.mobilePhone, s.homePhone, s.otherPhone ' +
      'FROM ministry_person AS p ' +
      'JOIN simplesecuritymanager_user AS ssm ON p.fk_ssmUserID = ssm.userID ' +
      'LEFT JOIN ministry_staff AS s ON p.personID = s.person_id ' +
      'WHERE '
    
    if account_numbers.count > 0
      query = query + "p.accountNo IN (#{account_numbers.join(',')})"
    end
    if guids.count > 0 and account_numbers.count > 0
      query = query + ' OR '
    end
    if guids.count > 0
      query = query + "ssm.globallyUniqueID IN (#{guids.join(',')})"
    end
    
    return false if !result = Sitrack.find_by_sql(query)

    for line in result
      if u = User.find_by_guid(line[:globallyUniqueID]) or u = find_by_account_number(line[:accountNo])
        if !process_user(line, period)
          logger.info "Failed to update user with params: #{line.inspect}"
        end
      end
    end

    return true
  end

  def self.period_query(p)
    result = nil
    ActiveRecord::Base.silence_auto_explain do
      # no automatic EXPLAIN is triggered here
      result = Sitrack.find_by_sql(
        'SELECT t.caringRegion, t.asgYear, t.status, t.internType, t.tenure, t.asgTeam, t.asgCity, t.asgState, t.asgCountry, t.asgContinent, p.accountNo, p.firstName, p.lastName, p.preferredName, ssm.globallyUniqueID, m.coachName, m.monthlyGoal, m.oneTimeGoal, s.email, s.mobilePhone, s.homePhone, s.otherPhone ' +
        'FROM sitrack_tracking AS t ' +
        'JOIN hr_si_applications AS a ON a.applicationID = t.application_id ' +
        'JOIN ministry_person AS p ON a.fk_personID = p.personID ' +
        'JOIN simplesecuritymanager_user AS ssm ON p.fk_ssmUserID = ssm.userID ' +
        # Might not be able to grab these tables, it's OK
        'LEFT JOIN ministry_staff AS s ON a.fk_personID = s.person_id ' +
        'LEFT JOIN sitrack_mpd AS m on m.application_id = a.applicationID ' +
        "WHERE t.caringRegion='#{p.region.name}' AND t.asgYear='#{p.year}-#{p.year+1}' AND p.accountNo IS NOT NULL"
        )
    end

    return false if !result

    ### Process result

    # With groups, have to deal with poorly capitalized coach names
    # So, {'luke yeager' => {1 => 'Luke Yeager', 2 => 'Luke YEAGER', ...}, ...}
    groups = Hash.new
    # With teams, have to deal with missing and conflicting additional data (city, state, country, etc)
    # So, {123 => {:city => [nil, 'Austin', 'AUSTIN'], :state => {...}, ...}, 124 => {...}, ...}
    teams = Hash.new

    for line in result
      if user = process_user(line, p)
        begin
          # Create or update assignment
          assn = Assignment.find_by_period_id_and_user_id(p.id, user.id) || Assignment.new(:period_id => p.id, :user_id => user.id)
          if line['tenure'] and line['internType']
            assn.intern_type = "#{line['tenure']} #{line['internType']}"
          elsif line['internType']
            assn.intern_type = line['internType']
          else
            assn.intern_type = nil
          end
          assn.status = line['status']
          
          # Set assignment team
          if sitrack_id = line['asgTeam']
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
            teams[sitrack_id][:city] << line['asgCity']
            teams[sitrack_id][:state] << line['asgState']
            teams[sitrack_id][:country] << line['asgCountry']
            teams[sitrack_id][:continent] << line['asgContinent']
          end
          
          # Set assignment group
          if name = line['coachName']
            name = Group.capitalize_name(name)
            if !group = Group.find_by_period_id_and_coach_name(p.id, name)
              group = Group.new(:period_id => p.id, :coach_name => name)
              group.save
            end
            assn.group = group
          end

          assn.save!

          # Create or update goals
          if amt = line['monthlyGoal']
            goal = assn.goals.find_by_frequency(12) || assn.goals.build(:frequency => 12)
            goal.amount = amt
            goal.save!
          end
          if amt = line['oneTimeGoal']
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
        logger.debug ">>>>> Invalid account number: #{line['accountNo']}"
      end
    end

    # Process team data
    teams.each do |sitrack_id, hash|
      if team = Team.find_by_period_id_and_sitrack_id(p.id, sitrack_id)
        team.city = process_team_data(hash[:city])
        team.state = process_team_data(hash[:state])
        team.country = process_team_data(hash[:country])
        team.continent = process_team_data(hash[:continent])

        team.save!
      end
    end

    # Delete empty teams
    for team in p.teams
      team.destroy if team.assignments.count == 0
    end

    # Delete empty groups
    for group in p.groups
      group.destroy if group.assignments.count == 0
    end

    return true
  end

  # Creates or updates a User from a query result
  def self.process_user(params, period = nil)
    user = User.find_by_guid(params[:globallyUniqueID]) || User.find_by_account_number(params[:accountNo]) || User.new
    user.guid = params[:globallyUniqueID]
    user.account_number = params[:accountNo]
    user.first_name = params[:firstName]
    user.preferred_name = params[:preferredName]
    user.last_name = params[:lastName]
    user.email = params[:email]
    user.phone = params[:mobilePhone] || params[:homePhone] || params[:otherPhone]
    user.time_zone ||= period.region.time_zone if period

    return user.save ? user : nil
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
