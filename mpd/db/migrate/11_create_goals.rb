class CreateGoals < ActiveRecord::Migration
  def up
    create_table :goals do |t|
			t.integer :assignment_id, :null => false
			t.integer :frequency, :null => false
			t.decimal :amount, :null => false
    end
		
		execute <<-SQL
			ALTER TABLE goals
				ADD CONSTRAINT fk_goals_assignments
				FOREIGN KEY (assignment_id)
				REFERENCES assignments(id)
		SQL

		a = Assignment.first
		a.goals.new(:frequency => 0, :amount => 17282)
		a.goals.new(:frequency => 12, :amount => 2080)
		a.save
  end

	def down
		drop_table :goals
	end
end
