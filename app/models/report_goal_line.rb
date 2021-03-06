class ReportGoalLine < ActiveRecord::Base
  attr_accessible :report_id, :frequency, :inhand, :pledged

  belongs_to :report

  validates :frequency, :inhand, :pledged, :numericality => true
end
