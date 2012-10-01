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

end
