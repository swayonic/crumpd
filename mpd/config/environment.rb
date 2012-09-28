# Load the rails application
require File.expand_path('../application', __FILE__)

# Not necessary, gets set in /etc/apache2/httpd.conf
#ENV['RAILS_ENV'] = 'development'

# Initialize the rails application
Mpd::Application.initialize!

