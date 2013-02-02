class Group < ActiveRecord::Base
  attr_accessible :period_id, :name, :coach_name

	belongs_to :period
	has_many :group_coaches
	has_many :coaches, :through => :group_coaches, :source => :user
	has_many :assignments
	has_many :members, :through => :assignments, :source => :user

	def can_view?(u)
		return true if u.is_admin
		return true if period.admins.include?(u)
		return true if coaches.include?(u)
		return true if members.include?(u)
		return false
	end

	def can_edit?(u)
		return false if period.keep_updated
		return true if u.is_admin
		return true if period.admins.include?(u)
		return false
	end

	def can_edit_coaches?(u)
		return true if u.is_admin
		return true if period.admins.include?(u)
		return false
	end

	def can_view_list?(u)
		return true if u.is_admin
		return true if period.admins.include?(u)
		return true if coaches.include?(u)
		return false
	end
end
