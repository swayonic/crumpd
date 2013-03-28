class Bmark < ActiveRecord::Base
  attr_accessible :period_id, :date, :percentage

	belongs_to :period

  validates :percentage, :numericality => { :only_integer => true }

end
