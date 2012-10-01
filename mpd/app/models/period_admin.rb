class PeriodAdmin < ActiveRecord::Base
	attr_accessible :user_id

	belongs_to :period
	belongs_to :user

end
