class Team < ActiveRecord::Base
  attr_accessible :period_id, :name, :leader_name

	belongs_to :period
	has_many :assignments
	has_many :members, :through => :assignments, :source => :user, :order => 'last_name, first_name'
	has_many :team_leaders
	has_many :leaders, :through => :team_leaders, :source => :user, :order => 'last_name, first_name'

	def can_view?(u)
		return true if u.is_admin
		return true if period.admins.include?(u)
		return true if members.include?(u)
		return false
	end

	def can_edit?(u)
		return false if period.keep_updated
		return true if u.is_admin
		return true if period.admins.include?(u)
		return false
	end
	
	def can_view_list?(u)
		return true if u.is_admin
		return true if period.admins.include?(u)
		return false
	end

end
