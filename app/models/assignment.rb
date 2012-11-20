class Assignment < ActiveRecord::Base
  attr_accessible :user_id, :period_id, :team_id, :group_id

	belongs_to :user
	belongs_to :period
	belongs_to :group
	belongs_to :team
	has_many :pledges
	has_many :reports, :order => 'created_at DESC'
	has_many :goals, :order => 'frequency'

	# TODO: validate group and team in same period

	#(onetime_goal and onetime_goal != 0) ? (Float(onetime_pledged) / onetime_goal).round(4) : 0
	def goal_total(f)
		total = 0
		for g in self.goals.select{|g| g.frequency == f}
			total = g.amount
		end
		return total
	end

	def goal_pledged(f)
		pledges.select{|p| p.frequency == f}.map{|p| p.amount}.sum
	end

	def goal_inhand(f)
		pledges.in_hand.select{|p| p.frequency == f}.map{|p| p.amount}.sum
	end

	def can_view?(u)
		return true if can_edit?(u)
		return true if team and team.leaders.include?(u)
		return true if group and group.coaches.include?(u)
		return false
	end

	def can_edit?(u)
		return true if u.is_admin
		return true if u == self.user
		return true if period.admins.include?(u)
		return false
	end

	def can_view_pledges?(u)
		return true if can_edit_pledges?(u)
		return true if group and group.coaches.include?(u)
		return false
	end

	def can_edit_pledges?(u)
		return true if u.is_admin
		return true if u == self.user
		return true if period.admins.include?(u)
		return false
	end

end
