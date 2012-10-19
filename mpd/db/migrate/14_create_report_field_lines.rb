class CreateReportFieldLines < ActiveRecord::Migration
  def up
    create_table :report_field_lines do |t|
			t.integer :report_id, :null => false
			t.integer :report_field_id, :null => false
			t.string :value
    end
		
		execute <<-SQL
			ALTER TABLE report_field_lines
				ADD CONSTRAINT fk_report_field_lines_reports
				FOREIGN KEY (report_id)
				REFERENCES reports(id)
		SQL
		execute <<-SQL
			ALTER TABLE report_field_lines
				ADD CONSTRAINT fk_report_field_lines_report_fields
				FOREIGN KEY (report_field_id)
				REFERENCES report_fields(id)
		SQL
  end

	def down
		drop_table :report_field_lines
	end
end
