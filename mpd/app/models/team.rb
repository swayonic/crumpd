class Team < ActiveRecord::Base
  attr_accessible :end, :name, :start, :period_id

	belongs_to :period
	has_many :assignments
	has_many :members, :through => :assignments, :source => :user, :order => "last_name, first_name"
	has_many :team_leaders
	has_many :leaders, :through => :team_leaders, :source => :user, :order => "last_name, first_name"

end
