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

end
