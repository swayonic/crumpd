class Period < ActiveRecord::Base
  attr_accessible :end, :name, :start

	has_many :groups
	has_many :teams
	has_many :period_admins
	has_many :admins, :through => :period_admins, :source => :user

	scope :active, lambda { where('(start is null or ? >= start) and (end is null or ? <= end)', Date.today, Date.today ) }
	scope :past, lambda { where('? > end', Date.today ) }
	scope :future, lambda { where('? < start', Date.today ) }

end
