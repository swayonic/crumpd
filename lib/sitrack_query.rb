require 'net/http'

module SitrackQuery
	class Query

		def self.user(account_number)
			logger = Rails.logger

			if Rails.env.development?
				uri = URI("http://localhost/sitrack/user?account_number=#{account_number}")
			else
				logger.info 'SitrackQuery::Query.user Not supported in production yet.'
				return nil
			end

			response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
				request = Net::HTTP::Get.new uri.request_uri
				
				http.request request
			end

			case response
			when Net::HTTPSuccess then
				json = JSON.parse(response.body)
				return json
			else
				logger.info "Error in SitrackQuery::Query.user : #{response.code}"
				return nil
			end
		end

	end
end

