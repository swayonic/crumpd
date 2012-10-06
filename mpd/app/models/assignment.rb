class Assignment < ActiveRecord::Base
  attr_accessible :monthly_goal, :one_time_goal

	belongs_to :user
	belongs_to :group
	belongs_to :team
	has_many :pledges

	# TODO: validate group and team in same period

	def period
		if !group.nil?
			return group.period
		elsif !team.nil?
			return team.period
		else
			return nil
		end
	end
end
