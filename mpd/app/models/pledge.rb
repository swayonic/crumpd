class Pledge < ActiveRecord::Base
  attr_accessible :name, :amount, :is_in_hand

	belongs_to :assignment

	#scope :in_hand
	#scope :not_in_hand
end
