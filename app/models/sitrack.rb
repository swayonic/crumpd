# This class should only be used in development
class Sitrack < ActiveRecord::Base
	self.table_name = 'sitrack_tracking' # Needs to know a table name

	establish_connection "sitrack_#{Rails.env}"

end
