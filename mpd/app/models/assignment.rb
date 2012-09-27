class Assignment < ActiveRecord::Base
  attr_accessible :monthly_goal, :one_time_goal

	belongs_to :user
	belongs_to :group
	belongs_to :team
end
