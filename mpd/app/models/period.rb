class Period < ActiveRecord::Base
  attr_accessible :end, :name, :start

	has_many :groups
	has_many :teams
	has_many :period_admins
	has_many :admins, :through => :period_admins, :source => :user

end
