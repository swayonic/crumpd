# This class should only be used in development
class Sitrack < ActiveRecord::Base
	self.table_name = 'sitrack_tracking' # Needs to know a table name

	establish_connection(
		:adapter => 'mysql2',
		:host => '108.166.64.232',
		:username => 'luke.yeager',
		:password => 'bugatti',
		:database => 'prod'
	)

	def self.download(period = nil)
		return false if !period.keep_updated?

		# With groups, have to deal with poorly capitalized coach names
		# So, {'luke yeager' => {1 => 'Luke Yeager', 2 => 'Luke YEAGER', ...}, ...}
		groups = Hash.new
		# With teams, have to deal with missing and conflicting additional data (city, state, country, etc)
		# So, {123 => {:city => [nil, 'Austin', 'AUSTIN'], :state => {...}, ...}, 124 => {...}, ...}
		teams = Hash.new

		lines = period_query(period)

		return false if lines.count == 0

		for line in lines
			if account_number = User.cleanup_account_number(line[:accountNo])
				begin
					# Update or create user info
					user = User.find_by_account_number(account_number) || User.new(:account_number => account_number)
					user.first_name = line[:firstName] if line[:firstName]
					user.last_name = line[:lastName] if line[:lastName]
					user.preferred_name = line[:preferredName] if line[:preferredName]
					user.phone = line[:mobilePhone] || line[:homePhone] || line[:otherPhone] || user.phone
					user.email = line[:email].downcase if line[:email]
					user.save!

					# Create or update assignment
					assn = Assignment.find_by_period_id_and_user_id(period.id, user.id) || Assignment.new(:period_id => period.id, :user_id => user.id)
					if line[:tenure] and line[:internType]
						assn.intern_type = "#{line[:tenure]} #{line[:internType]}"
					elsif line[:internType]
						assn.intern_type = line[:internType]
					else
						assn.intern_type = nil
					end
					assn.status = line[:status]
					
					# Set assignment team
					if sitrack_id = line[:asgTeam]
						# Find existing team or create one
						if !team = Team.find_by_period_id_and_sitrack_id(period.id, sitrack_id)
							team = Team.new(:period_id => period.id, :sitrack_id => sitrack_id)
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
						if !group = Group.find_by_period_id_and_coach_name(period.id, name)
							group = Group.new(:period_id => period.id, :coach_name => name)
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
				logger.debug ">>>>> Not valid account number"
			end
		end

		# Process team data
		teams.each do |sitrack_id, hash|
			if team = Team.find_by_period_id_and_sitrack_id(period.id, sitrack_id)
				team.city = process_team_data(hash[:city])
				team.state = process_team_data(hash[:state])
				team.country = process_team_data(hash[:country])
				team.continent = process_team_data(hash[:continent])

				team.save!
			end
		end

		# Delete empty teams
		for team in period.teams
			team.destroy if team.assignments.count == 0
		end

		# Delete empty groups
		for group in period.groups
			group.destroy if group.assignments.count == 0
		end

		return true
	end

	private

	def self.period_query(period)
		ActiveRecord::Base.silence_auto_explain do
	  	# no automatic EXPLAIN is triggered here
			return Sitrack.find_by_sql(
				'SELECT t.status, t.internType, t.tenure, t.asgTeam, t.asgCity, t.asgState, t.asgCountry, t.asgContinent, p.accountNo, p.firstName, p.lastName, p.preferredName, m.coachName, m.monthlyGoal, m.oneTimeGoal, s.email, s.mobilePhone, s.homePhone, s.otherPhone ' +
				'FROM sitrack_tracking AS t ' +
				'JOIN hr_si_applications AS a ON a.applicationID = t.application_id ' +
				'JOIN ministry_person AS p ON a.fk_personID = p.personID ' +
				# Might not be able to grab these tables, it's OK
				'LEFT JOIN ministry_staff AS s ON a.fk_personID = s.person_id ' +
				'LEFT JOIN sitrack_mpd AS m on m.application_id = a.applicationID ' +
				"WHERE t.caringRegion = '#{period.region.name}' AND t.asgYear = '#{period.year}-#{period.year + 1}' AND p.accountNo IS NOT NULL"
				)
		end
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
