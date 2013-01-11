class Assignment < ActiveRecord::Base
  attr_accessible :user_id, :period_id, :team_id, :group_id, :intern_type, :status

	belongs_to :user
	belongs_to :period
	belongs_to :group
	belongs_to :team
	has_many :pledges
	has_many :reports, :order => 'created_at DESC'
	has_many :goals, :order => 'frequency'

	# TODO: validate group and team in same period

	def latest_report
		return nil if reports.count == 0
		return reports.first
	end

	def goal_amt(f)
		total = 0
		for g in self.goals.select{|g| g.frequency == f}
			total = g.amount
		end
		return total
	end

	def goal_pledged(f)
		pledges.not_in_hand.select{|p| p.frequency == f}.map{|p| p.amount}.sum
	end

	def goal_pledged_pct(f)
		Goal.pct(goal_pledged(f), goal_amt(f))
	end

	def goal_inhand(f)
		pledges.in_hand.select{|p| p.frequency == f}.map{|p| p.amount}.sum
	end
	
	def goal_inhand_pct(f)
		Goal.pct(goal_inhand(f), goal_amt(f))
	end

	def goal_total(f)
		pledges.select{|p| p.frequency == f}.map{|p| p.amount}.sum
	end
	
	def goal_total_pct(f)
		Goal.pct(goal_total(f), goal_amt(f))
	end

	def can_view?(u)
		return true if u.is_admin
		return true if u == self.user
		return true if period.admins.include?(u)
		return true if group and group.coaches.include?(u)
		return false
	end

	def can_edit?(u)
		return false if period.keep_updated
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
	
	def can_view_reports?(u)
		can_view?(u)
	end
	
	def can_edit_reports?(u)
		return true if u.is_admin
		return true if u == self.user
		return true if period.admins.include?(u)
		return false
	end

end
