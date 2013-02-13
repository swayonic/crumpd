class Period < ActiveRecord::Base
  attr_accessible :region_id, :year, :keep_updated
	
	scope :updated, where(:keep_updated => true)

	belongs_to :region
	has_many :assignments, :dependent => :destroy
	has_many :reports, :through => :assignments
	has_many :groups, :dependent => :destroy
	has_many :teams, :dependent => :destroy
	has_many :period_admins, :dependent => :destroy
	has_many :admins, :through => :period_admins, :source => :user
	has_many :report_fields, :order => 'list_index', :dependent => :destroy
	has_many :bmarks, :order => 'date', :dependent => :destroy


	def name
		"#{region.display_name} #{year}"
	end

	def can_view?(u)
		return true if u.is_admin
		return true if admins.include?(u)
		return false
	end

	def can_edit?(u)
		#return false if keep_updated
		return true if u.is_admin
		return true if admins.include?(u)
		return false
	end

	def can_edit_admins?(u)
		return true if u.is_admin
		return true if admins.include?(u)
		return false
	end

end
