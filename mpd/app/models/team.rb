class Team < ActiveRecord::Base
  attr_accessible :end, :name, :start

	belongs_to :period
	has_many :assignments
	has_many :members, :through => :assignments, :source => :user, :order => "last_name, first_name DESC"
	has_many :team_leaders
	has_many :leaders, :through => :team_leaders, :source => :user, :order => "last_name, first_name DESC"

end
