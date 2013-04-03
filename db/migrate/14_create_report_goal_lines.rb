class CreateReportGoalLines < ActiveRecord::Migration
  def up
    create_table :report_goal_lines do |t|
      t.integer :report_id, :null => false
      t.integer :frequency, :null => false
      t.decimal :inhand, :default => 0
      t.decimal :pledged, :default => 0
    end

    execute <<-SQL
      ALTER TABLE #{ReportGoalLine.table_name}
        ADD CONSTRAINT fk_report_goal_lines_reports
        FOREIGN KEY (report_id)
        REFERENCES #{Report.table_name}(id)
    SQL
  end

  def down
    drop_table :report_goal_lines
  end
end
