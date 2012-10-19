class CreateReports < ActiveRecord::Migration
  def up
    create_table :reports do |t|
      t.integer :assignment_id
      t.timestamps
			t.integer :updated_by
    end
		
		execute <<-SQL
			ALTER TABLE reports
				ADD CONSTRAINT fk_reports_assignments
				FOREIGN KEY (assignment_id)
				REFERENCES assignments(id)
		SQL
		execute <<-SQL
			ALTER TABLE reports
				ADD CONSTRAINT fk_reports_users
				FOREIGN KEY (updated_by)
				REFERENCES users(id)
		SQL

  end

	def down
		drop_table :reports
	end
end
