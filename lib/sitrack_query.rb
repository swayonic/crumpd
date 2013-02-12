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

			periods = Array.new
			periods << periods
			make_request(periods, Array.new)

			#TODO: Do something with it
		end

		# Queries sitrack to update all periods that are marked for updating
		def self.update_all
			periods = Array.new
			users = Array.new

			for u in User.admin
				users << u.account_number
			end

			for p in Period.updated
				periods << p
				for u in p.admins
					users << u.account_number
				end
				for g in p.groups
					for u in g.coaches
						users << u.account_number
					end
				end
			end

			make_request(periods, users.uniq)

			# TODO: Do something with it
		end

		private
		
		def self.make_request(periods, users)
			logger = Rails.logger

			if Rails.env.development?
				uri = URI('http://localhost/sitrack/dump')
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

	end
end

