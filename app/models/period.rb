class Period < ActiveRecord::Base
  attr_accessible :region_id, :year, :keep_updated

	belongs_to :region
	has_many :assignments
	has_many :reports, :through => :assignments
	has_many :groups, :order => 'name'
	has_many :teams, :order => 'name'
	has_many :period_admins
	has_many :admins, :through => :period_admins, :source => :user
	has_many :report_fields, :order => 'list_index'
	has_many :bmarks, :order => 'date'

	scope :updated, where(:keep_updated => true)

	def name
		"#{region.display_name} #{year}"
	end

	def can_view?(u)
		return true if u.is_admin
		return true if admins.include?(u)
		return false
	end

	def can_edit?(u)
		return false if keep_updated
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
