class Pledge < ActiveRecord::Base
  attr_accessible :name, :amount, :frequency, :is_in_hand, :assignment_id

	belongs_to :assignment

	scope :in_hand, where(:is_in_hand => true)
	scope :not_in_hand, where(:is_in_hand => false)
	scope :monthly, where(:frequency => 12)
	scope :onetime, where(:frequency => 1)
end
