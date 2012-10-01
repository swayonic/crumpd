class Group < ActiveRecord::Base
  attr_accessible :name, :period_id

	belongs_to :period
	has_many :group_coaches
	has_many :coaches, :through => :group_coaches, :source => :user, :order => "last_name, first_name"
	has_many :assignments
	has_many :members, :through => :assignments, :source => :user, :order => "last_name, first_name"

end
