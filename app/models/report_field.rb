class ReportField < ActiveRecord::Base
  attr_accessible :period_id, :list_index, :name, :field_type, :required, :description, :active

	belongs_to :period
	has_many :report_field_lines

  validates_associated :report_field_lines #If we change the field, let's make sure the associated lines are still valid
  validates :list_index, :numericality => { :only_integer => true }
  #TODO: More validations

	def self.type_array
		return [
			['Integer', 'I'],
			['Decimal', 'D'],
			['String', 'S'],
			['Text', 'T'] ]
	end

	def field_type_pretty
		for option in ReportField.type_array
			return option[0] if option[1] == field_type
		end
		return nil
	end

	def is_required?
		required
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
