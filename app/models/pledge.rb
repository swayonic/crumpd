class Pledge < ActiveRecord::Base
  attr_accessible :name, :amount, :frequency, :is_in_hand, :assignment_id

  belongs_to :assignment

  scope :in_hand, where(:is_in_hand => true)
  scope :not_in_hand, where(:is_in_hand => false)

  validates :name, :presence => true
  validates :amount, :presence => true, :numericality => {:greater_than_or_equal_to => 0}
end
