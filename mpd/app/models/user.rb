class User < ActiveRecord::Base
  attr_accessible :account_number, :email, :first_name, :is_admin, :last_name, :phone

	has_many :assignments
	has_many :group_coaches
	has_many :team_leaders
	has_many :period_admins

	has_many :groups_as_member, :through => :assignments, :source => :group
	has_many :groups_as_coach, :through => :group_coaches, :source => :group
	has_many :teams_as_member, :through => :assignments, :source => :team
	has_many :teams_as_leader, :through => :team_leaders, :source => :team
	has_many :periods, :through => :period_admins

	def display_name
		"#{first_name} #{last_name}"
	end

end
