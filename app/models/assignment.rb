class Assignment < ActiveRecord::Base
  attr_accessible :user_id, :period_id, :team_id, :group_id, :intern_type, :status

  def self.active
    Assignment.all.select{|a| a.active?}
  end

  def active?
    return ['accepted','placed','on_assignment','alumni'].include?(status)
  end

  belongs_to :user
  belongs_to :period
  belongs_to :group
  belongs_to :team
  has_many :pledges, :dependent => :destroy
  has_many :reports, :order => 'date DESC', :dependent => :destroy
  has_many :goals, :order => 'frequency', :dependent => :destroy

  validate do
    if group and period and group.period_id != period_id
      self.errors.add(:group_id, "group.period doesn't match period")
    end
    if team and period and team.period_id != period_id
      self.errors.add(:team_id, "team.period doesn't match period")
    end
  end

  def latest_report
    return nil if reports.count == 0
    return reports.first
  end

  def goal_amt(f)
    total = nil
    for goal in self.goals.select{|g| g.frequency == f}
      total = goal.amount
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

  def combined_pledged_pct
    amt = 0
    goal = 0
    for g in goals
      amt = amt + goal_pledged(g.frequency) * (g.frequency == 0 ? 1 : g.frequency)
      goal = goal + goal_amt(g.frequency) * (g.frequency == 0 ? 1 : g.frequency) if goal_amt(g.frequency)
    end
    return Goal.pct(amt, goal)
  end

  def combined_inhand_pct
    amt = 0
    goal = 0
    for g in goals
      amt = amt + goal_inhand(g.frequency) * (g.frequency == 0 ? 1 : g.frequency)
      goal = goal + goal_amt(g.frequency) * (g.frequency == 0 ? 1 : g.frequency) if goal_amt(g.frequency)
    end
    return Goal.pct(amt, goal)
  end

  def combined_total_pct
    amt = 0
    goal = 0
    for g in goals
      amt = amt + goal_total(g.frequency) * (g.frequency == 0 ? 1 : g.frequency)
      goal = goal + goal_amt(g.frequency) * (g.frequency == 0 ? 1 : g.frequency) if goal_amt(g.frequency)
    end
    return Goal.pct(amt, goal)
  end

  # Returns the number of unique names in pledges
  #   Used for building partners_lines
  def partners_count
    pledges.map{|p| p.name.strip}.uniq.count
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
