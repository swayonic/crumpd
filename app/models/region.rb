class Region < ActiveRecord::Base
  attr_accessible :name, :title

	has_many :periods

	def display_name
		title.nil? ? name : title
	end

end
