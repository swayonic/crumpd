require 'net/http'

desc "This task is called by the Heroku scheduler add-on"
task :get_data_dump => :environment do
	if Rails.env.development?
		uri = URI('http://localhost/datadump')
	else
		puts 'Not supported in production yet.'
		return
	end

	periods = Array.new
	people = Array.new

	for p in Period.all
		periods << "#{p.region.name}_#{p.year}"
		for u in p.admins
			people << u.account_number
		end
		for g in p.groups
			for u in g.coaches
				people << u.account_number
			end
		end
	end

	response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
		request = Net::HTTP::Post.new uri.path
		request.set_form_data('periods' => periods.join('+'), 'people' => people.join('+'))

		puts 'making request...'
		http.request request
	end

	dump = DumpRecord.new
	dump.status = response.code

	case response
	when Net::HTTPSuccess then
		json = JSON(response.body)
		json.each do |key, value|
			puts "key:#{key}, value:#{value}"
		end
	else
		puts "Error: #{response.code}"
	end

	dump.save
end
