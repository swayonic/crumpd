class User < ActiveRecord::Base
  attr_accessible :account_number, :first_name, :last_name, :preferred_name, :email, :is_admin

	has_many :assignments
	has_many :group_coaches
	has_many :team_leaders
	has_many :period_admins

	has_many :groups_as_member, :through => :assignments, :source => :group, :order => "name"
	has_many :groups_as_coach, :through => :group_coaches, :source => :group, :order => "name"
	has_many :teams_as_member, :through => :assignments, :source => :team, :order => "name"
	has_many :teams_as_leader, :through => :team_leaders, :source => :team, :order => "name"
	has_many :periods, :through => :period_admins

	validates :email, :format => { 
		:with => /^[_a-z0-9-]+(\.[_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,4})$/,
		:allow_nil => true,
		:allow_blank => true,
		:message => "Invalid format"
		}

	def display_name
		if preferred_name.nil?
			return "#{first_name} #{last_name}"
		else
			return "#{preferred_name} #{last_name}"
		end
	end

	# TODO: Is there a way to do this with fewer queries?
	def can_view?(u)
		return false #I'm disabling this for now

		return true if can_edit?(u)
		periods.each do |p|
			return true if p.admins.include?(u)
		end
		teams_as_leader.each do |t|
			return true if t.period.admins.include?(u)
			return true if t.leaders.include?(u)
			return true if t.members.include?(u)
		end
		teams_as_member.each do |t|
			return true if t.period.admins.include?(u)
			return true if t.leaders.include?(u)
			return true if t.members.include?(u)
		end
		groups_as_coach.each do |g|
			return true if g.period.admins.include?(u)
			return true if g.coaches.include?(u)
			return true if g.members.include?(u)
		end
		groups_as_member.each do |g|
			return true if g.period.admins.include?(u)
			return true if g.coaches.include?(u)
			return true if g.members.include?(u)
		end
		return false
	end

	def can_edit?(u)
		return false #I'm disabling this for now

		return true if u.is_admin
		return true if u == self
		return false
	end

end
