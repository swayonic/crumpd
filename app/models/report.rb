class Report < ActiveRecord::Base
	attr_accessible :date

	belongs_to :assignment

	has_many :goal_lines, :class_name => 'ReportGoalLine', :order => 'frequency', :dependent => :destroy
	validates_associated :goal_lines, :on => []

	has_many :field_lines, :class_name => 'ReportFieldLine', :dependent => :destroy
	validates_associated :field_lines, :on => []

	validate do
		goal_lines.each do |l|
			if !l.valid?
				l.errors.each do |attr, msg|
					title = Goal.title(l.frequency)
					title += " in-hand" if attr == :inhand
					title += " pledged" if attr == :pledged
					self.errors.add(:goal_lines, title + ' ' + msg)
				end
			end
		end
		field_lines.each do |l|
			if !l.valid?
				l.errors.each do |attr, msg|
					self.errors.add(:field_lines, msg)
				end
			end
		end
	end
end
