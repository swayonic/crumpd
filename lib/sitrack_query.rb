require 'net/http'

module SitrackQuery
	class Query

		# Queries sitrack for a user's information from an account_number
		def self.find_user(account_number)
			users = Array.new
			users << account_number

			result = make_request(Array.new, users)
			if result.nil? or results.empty?
				return {:found => false}.to_json
			else
				line = result[0]
				return {
					:found => true,
					:guid => line['globallyUniqueID'],
					:account_number => line['accountNo'],
					:first_name => line['firstName'],
					:preferred_name => line['preferredName'],
					:last_name => line['lastName'],
					:email => line['email'],
					:phone => line['mobilePhone'] || line['homePhone'] || line['otherPhone']
					}.to_json
			end
		end

		# Queries sitrack to update a single period
		def self.find_period(period)
			return false if !period or !period.keep_updated

			users = period.admins
			for g in period.groups
				users.concat g.coaches
			end
			users = users.map{|u| u.account_number || u.guid}.uniq

			periods = Array.new
			periods << period

			result = make_request(periods, users)

			process_result(result)
		end

		# Queries sitrack to update all periods that are marked for updating
		def self.update_all
			periods = Array.new
			users = Array.new

			for u in User.admin
				users << u
			end

			for p in Period.updated
				periods << p
				for u in p.admins
					users << u
				end
				for g in p.groups
					for u in g.coaches
						users << u
					end
				end
			end

			users = users.map{|u| u.account_number || u.guid}.uniq

			result = make_request(periods, users)

			process_result(result)
		end

		private
		
		def self.make_request(periods, users)
			logger = Rails.logger

			if Rails.env.development?
				uri = URI('http://localhost:3000/sitrack/dump')
			else
				puts 'Not supported in production yet.'
				return nil
			end

			periods = periods.map{|p| "#{p.region.name}_#{p.year}"}

			response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
				request = Net::HTTP::Post.new uri.path
				request.set_form_data(
					'periods' => periods.join('+'),
					'users' => users.join('+')
					)

				http.request request
			end

			case response
			when Net::HTTPSuccess then
				json = JSON.parse(response.body)
				return json
			else
				logger.info "Error in SitrackQuery::Query.make_request : #{response.code}"
				return nil
			end
		end

		def self.process_result(json)
			return false if json.nil?
			
			if json['regions']
				process_regions_result(json['regions'])
			end

			if json['users']
				json['users'].each do |user|
					process_user_result(user)
				end
			end

			if json['periods']
				json['periods'].each do |period, assignments|
					process_period_result(period, assignments)
				end
			end

			return true
		end

		def self.process_user_result(json)
			return nil if json.nil?
			return nil if !account_number = User.cleanup_account_number(json['accountNo'])

			if user = User.find_by_guid(account_number)
				user.account_number = account_number
			elsif user = User.find_by_account_number(account_number)
				user.guid = json['globallyUniqueID'] || user.guid
			else
				user = User.new
				user.guid = json['globallyUniqueID'] || user.guid
				user.account_number = account_number
			end

			user.first_name = json['firstName'] || user.first_name
			user.last_name = json['lastName'] || user.last_name
			user.preferred_name = json['preferredName'] || user.preferred_name
			user.email = json['email'].downcase if json['email']
			user.phone = json['mobilePhone'] || json['homePhone'] || json['otherPhone'] || user.phone

			return user.save ? user : nil
		end

		def self.process_period_result(period, assignments)
			logger = Rails.logger

			if period =~ /^(\w+)_(\d{4})$/
				region = $1
				year = Integer($2)
			else
				return false
			end

			return false if !region = Region.find_by_name(region)
			return false if !period = Period.find_by_region_id_and_year(region.id, year)

			# With groups, have to deal with poorly capitalized coach names
			# So, {'luke yeager' => {1 => 'Luke Yeager', 2 => 'Luke YEAGER', ...}, ...}
			groups = Hash.new
			# With teams, have to deal with missing and conflicting additional data (city, state, country, etc)
			# So, {123 => {:city => [nil, 'Austin', 'AUSTIN'], :state => {...}, ...}, 124 => {...}, ...}
			teams = Hash.new

			for line in assignments
				if user = process_user_result(line)
					begin
						# Create or update assignment
						assn = Assignment.find_by_period_id_and_user_id(period.id, user.id) || Assignment.new(:period_id => period.id, :user_id => user.id)
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
							teams[sitrack_id][:city] << line['asgCity']
							teams[sitrack_id][:state] << line['asgState']
							teams[sitrack_id][:country] << line['asgCountry']
							teams[sitrack_id][:continent] << line['asgContinent']
						end
					
						# Set assignment group
						if name = line['coachName']
							name = Group.capitalize_name(name)
							if !group = Group.find_by_period_id_and_coach_name(period.id, name)
								group = Group.new(:period_id => period.id, :coach_name => name)
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

		def self.process_regions_result(json)
			json.each do |name|
				# Only allow all capitalized names (RR, GL, etc)
				if name and name =~ /^([A-Z]+)$/
					name = $1
					if !Region.find_by_name(name)
						r = Region.new
						r.name = name
						r.save
					end
				end
			end
		end

	end
end

