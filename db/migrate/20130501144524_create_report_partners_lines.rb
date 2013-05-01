class CreateReportPartnersLines < ActiveRecord::Migration
  def up
    create_table :report_partners_lines do |t|
      t.integer :report_id, :null => false
      t.integer :total
      t.integer :new
    end

    execute <<-SQL
      ALTER TABLE #{ReportPartnersLine.table_name}
        ADD CONSTRAINT fk_report_parners_lines_reports
        FOREIGN KEY (report_id)
        REFERENCES #{Report.table_name}(id)
    SQL
  end

  def down
    drop_table :report_partners_lines
  end
end
