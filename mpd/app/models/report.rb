class Report < ActiveRecord::Base
  attr_accessible :account_balance, :assignment_id, :had_coach_convo, :letter_hours, :monthly_inhand, :mpd_hours, :new_monthly_amt, :new_monthly_count, :new_monthly_pledged, :new_onetime_amt, :new_onetime_count, :new_referrals, :num_contacts, :num_phone_convos, :num_phone_dials, :num_precall_letters, :num_support_letters, :onetime_inhand, :onetime_pledged, :phone_hours, :prayer_requests

	belongs_to :assignment

	has_many :goal_lines, :class_name => 'ReportGoalLine'
	validates_associated :goal_lines, :on => []

	has_many :field_lines, :class_name => 'ReportFieldLine'
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
