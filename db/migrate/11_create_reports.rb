class CreateReports < ActiveRecord::Migration
  def up
    create_table :reports do |t|
      t.integer :assignment_id, :null => false
      t.datetime :date
      t.timestamps
      t.integer :updated_by
    end

    execute <<-SQL
      ALTER TABLE #{Report.table_name}
        ADD CONSTRAINT fk_reports_assignments
        FOREIGN KEY (assignment_id)
        REFERENCES #{Assignment.table_name}(id)
    SQL
    execute <<-SQL
      ALTER TABLE #{Report.table_name}
        ADD CONSTRAINT fk_reports_users
        FOREIGN KEY (updated_by)
        REFERENCES #{User.table_name}(id)
    SQL

  end

  def down
    drop_table :reports
  end
end
