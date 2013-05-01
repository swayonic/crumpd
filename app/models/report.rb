class Report < ActiveRecord::Base
  attr_accessible :date

  belongs_to :assignment

  has_many :partners_lines, :class_name => 'ReportPartnersLine', :dependent => :destroy
  has_many :goal_lines, :class_name => 'ReportGoalLine', :order => 'frequency', :dependent => :destroy
  has_many :field_lines, :class_name => 'ReportFieldLine', :dependent => :destroy

  def partners_line
    partners_lines.first || partners_lines.new
  end

  validate do
    partners_lines.each do |l|
      l.errors.each do |attr, msg|
        self.errors.add(:partners_lines, 'Number of Partners ' + msg)
      end
    end
    goal_lines.each do |l|
      l.errors.each do |attr, msg|
        title = Goal.title(l.frequency)
        title += " in-hand" if attr == :inhand
        title += " pledged" if attr == :pledged
        self.errors.add(:goal_lines, title + ' ' + msg)
      end
    end
    field_lines.each do |l|
      l.errors.each do |attr, msg|
        self.errors.add(:field_lines, msg)
      end
    end
  end

  def can_delete?(u)
    return true if u.is_admin?
    #return true if u == assignment.user
    return assignment.period.admins.include?(u)
  end
end
