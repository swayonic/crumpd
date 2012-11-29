class Group < ActiveRecord::Base
  attr_accessible :name, :period_id

	belongs_to :period
	has_many :group_coaches
	has_many :coaches, :through => :group_coaches, :source => :user, :order => "last_name, first_name"
	has_many :assignments
	has_many :members, :through => :assignments, :source => :user, :order => "last_name, first_name"

	def can_view?(u)
		return true if can_edit?(u)
		return true if coaches.include?(u)
		return true if members.include?(u)
		return false
	end

	def can_edit?(u)
		return true if u.is_admin
		return true if period.admins.include?(u)
		return false
	end

	def can_view_list?(u)
		return true if u.is_admin
		return true if period.admins.include?(u)
		return true if coaches.include?(u)
	end
end
