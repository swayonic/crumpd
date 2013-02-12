class User < ActiveRecord::Base
  attr_accessible :account_number, :first_name, :last_name, :preferred_name, :phone, :email, :is_admin

	has_many :assignments
	has_many :group_coaches
	has_many :team_leaders
	has_many :period_admins

	has_many :groups_as_member, :through => :assignments, :source => :group, :order => "name"
	has_many :groups_as_coach, :through => :group_coaches, :source => :group, :order => "name"
	has_many :teams_as_member, :through => :assignments, :source => :team, :order => "name"
	has_many :teams_as_leader, :through => :team_leaders, :source => :team, :order => "name"
	has_many :periods_as_admin, :through => :period_admins, :source => :period

	validates :email, :format => { 
		:with => /^[_a-z0-9-]+(\.[_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,4})$/,
		:allow_nil => true,
		:allow_blank => true,
		:message => "Invalid format"
		}
	
	def self.cleanup_account_number(accountNo)
		return nil if accountNo.nil? or accountNo.blank?
		return "00#{$2}#{$3}" if accountNo.strip =~ /^(00|)(\d{7})(S|)$/
		return nil
	end

	def display_name
		return "##{account_number}"	if first_name.nil? and last_name.nil?
		return last_name if first_name.nil?
		return first_name if last_name.nil?
		return "#{first_name} #{last_name}" if preferred_name.nil?
		
		return "#{preferred_name} #{last_name}"
	end

	def sort_name
		return "##{account_number}" if first_name.nil? and last_name.nil?
		return last_name if first_name.nil?
		return first_name if last_name.nil?
		return "#{last_name}, #{first_name}" if preferred_name.nil?
		
		return "#{last_name}, #{preferred_name}"
	end


	# Return all periods with which this user is affiliated
	def all_periods
		res = Array.new
		res.concat periods_as_admin
		res.concat assignments.map{|a| a.period}
		res.concat groups_as_coach.map{|g| g.period}
		#res.concat teams_as_leader.map{|t| t.period}
		return res.uniq
	end
	
	def can_view?(u)
		return true
	end

	def can_edit?(u)
		# Can't edit if they are a part of an updated Period
		for p in all_periods
			return false if p.keep_updated?
		end

		return true if u.is_admin
		return true if u == self
		return false
	end

end
