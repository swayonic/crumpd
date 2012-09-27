class Team < ActiveRecord::Base
  attr_accessible :end, :name, :start

	belongs_to :period
	has_many :assignments
	has_many :members, :through => :assignments, :source => :user
	has_many :team_leaders
	has_many :leaders, :through => :team_leaders, :source => :user

end
