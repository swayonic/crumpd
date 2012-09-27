class Group < ActiveRecord::Base
  attr_accessible :name

	belongs_to :period
	has_many :group_coaches
	has_many :coaches, :through => :group_coaches, :source => :user
	has_many :assignments
	has_many :members, :through => :assignments, :source => :user

end
