class Region < ActiveRecord::Base
  attr_accessible :name, :title

	has_many :periods

  validates_each :title do |record, attr, value|
    logger.debug "attr: #{attr}"
    logger.debug "value: #{value}"
    if value.nil? or value.strip.blank?
      record.title = nil
    else
      if value !~ /[a-zA-Z \-]+/
        record.errors.add(:attr, 'Invalid title format')
      end
    end
  end

	def display_name
		title.nil? ? name : title
	end
end
