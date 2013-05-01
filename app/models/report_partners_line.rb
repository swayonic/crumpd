class ReportPartnersLine < ActiveRecord::Base
  attr_accessible :report_id, :total, :new

  belongs_to :report

  validates :total, :numericality => true
  validates :new, :numericality => true, :allow_nil => true
end
