class ReportField < ActiveRecord::Base
  attr_accessible :period_id, :list_index, :name, :field_type, :required, :description, :active

	belongs_to :period
	has_many :report_field_lines
	validates_associated :report_field_lines #If we change the field, let's make sure the associated lines are still valid

	validates_each :list_index do |record, attr, value|
		puts 'validating...', value
		if value.nil? or value.blank? or ReportField.find_all_by_list_index_and_period_id(value, record.period_id).count > 0
			record.list_index = ReportField.where(:period_id => record.period_id).maximum(:list_index) + 1
		end
	end

	def is_integer?
		field_type == 'I'
	end
	def is_decimal?
		field_type == 'D'
	end
	def is_number?
		is_integer? or is_decimal?
	end
	def is_string?
		field_type == 'S'
	end
	def is_text?
		field_type == 'T'
	end
end
