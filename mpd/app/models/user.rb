class User < ActiveRecord::Base
  attr_accessible :account_number, :email, :first_name, :is_admin, :last_name, :phone

	has_many :assignments
	has_many :group_coaches
	has_many :team_leaders
	has_many :period_admins

	has_many :groups_as_member, :through => :assignments, :source => :group, :order => "name"
	has_many :groups_as_coach, :through => :group_coaches, :source => :group, :order => "name"
	has_many :teams_as_member, :through => :assignments, :source => :team, :order => "name"
	has_many :teams_as_leader, :through => :team_leaders, :source => :team, :order => "name"
	has_many :periods, :through => :period_admins, :order => "start DESC"

	validates :email, :format => { 
		:with => /^[_a-z0-9-]+(\.[_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,4})$/,
		:allow_nil => true,
		:allow_blank => true,
		:message => "Invalid format"
		}
	validates :phone, :format => { 
		:with => /^[0-9-]+$/,
		:allow_nil => true,
		:allow_blank => true,
		:message => "Invalid format"
		}

	def display_name
		"#{first_name} #{last_name}"
	end

	def can_view?(u)
		return true if can_edit?(u)
		periods.each do |p|
			return true if p.admins.include?(u)
		end
		teams_as_leader.each do |t|
			return true if t.period.admins.include?(u)
		end
		teams_as_member.each do |t|
			return true if t.period.admins.include?(u)
		end
		groups_as_coach.each do |g|
			return true if g.period.admins.include?(u)
		end
		groups_as_member.each do |g|
			return true if g.period.admins.include?(u)
		end
		return false
	end

	def can_edit?(u)
		return true if u.is_admin
		return true if u == self
		return false
	end

end
