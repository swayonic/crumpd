class Assignment < ActiveRecord::Base
  attr_accessible :monthly_goal, :onetime_goal, :user_id, :team_id, :group_id

	belongs_to :user
	belongs_to :period
	belongs_to :group
	belongs_to :team
	has_many :pledges
	has_many :reports, :order => 'created_at DESC'
	has_many :goals, :order => 'frequency'

	# TODO: validate group and team in same period

	def monthly_in_hand
		pledges.monthly.in_hand.map{ |p| p.amount }.sum
	end
	def monthly_in_hand_pct
		(monthly_goal && monthly_goal != 0) ? (Float(monthly_in_hand) / monthly_goal).round(4) : 0
	end

	def monthly_pledged
		pledges.monthly.map{ |p| p.amount }.sum
	end
	def monthly_pledged_pct
		(monthly_goal and monthly_goal != 0) ? (Float(monthly_pledged) / monthly_goal).round(4) : 0
	end

	def onetime_in_hand
		pledges.onetime.in_hand.map{ |p| p.amount }.sum
	end
	def onetime_in_hand_pct
		(onetime_goal and onetime_goal != 0) ? (Float(onetime_in_hand) / onetime_goal).round(4) : 0
	end

	def onetime_pledged
		pledges.onetime.map{ |p| p.amount }.sum
	end
	def onetime_pledged_pct
		(onetime_goal and onetime_goal != 0) ? (Float(onetime_pledged) / onetime_goal).round(4) : 0
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

end
