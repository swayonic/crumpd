class CreateGoals < ActiveRecord::Migration
  def up
    create_table :goals do |t|
      t.integer :assignment_id, :null => false
      t.integer :frequency, :null => false
      t.decimal :amount, :null => false
    end

    execute <<-SQL
      ALTER TABLE #{Goal.table_name}
        ADD CONSTRAINT fk_goals_assignments
        FOREIGN KEY (assignment_id)
        REFERENCES #{Assignment.table_name}(id)
    SQL
  end

  def down
    drop_table :goals
  end
end
