class ReportFieldLine < ActiveRecord::Base
  attr_accessible :report_id, :report_field_id, :value

  belongs_to :report
  belongs_to :report_field

  validates_each :value do |record, attr, value|
    if value.nil? or value.blank?
      if !record.report_field.required
        record[attr] = nil
      else
        record.errors.add(attr, "\"#{record.report_field.name}\" is a required field.")
      end
    elsif record.report_field.is_number?
      if value =~ /^\s*\d+(\.\d+)?\s*$/
        record[attr] = String(Integer(Float(value))) if record.report_field.field_type == 'I'
        record[attr] = String(Float(value)) if record.report_field.field_type == 'D'
      else
        record.errors.add(attr, "\"#{record.report_field.name}\" must be a number")
      end
    else # Not a number
      if value.length > 255
        record.errors.add(attr, "\"#{record.report_field.name}\" is too long. 255 characters is the maximum length.")
      end
    end
  end

end
