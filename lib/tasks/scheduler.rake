desc "This task is called by the Heroku scheduler add-on"
task :get_data_dump => :environment do
	puts 'Getting data dump...'
	u = User.first
	puts "The first user's name is: #{u.display_name}"
end
