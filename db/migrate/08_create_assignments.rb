class CreateAssignments < ActiveRecord::Migration
  def up
    create_table :assignments do |t|
      t.integer :user_id, :null => false
      t.integer :period_id, :null => false
      t.integer :team_id
      t.integer :group_id
      # TODO: What do these mean?
      t.string :intern_type
      t.string :status
    end
    
    execute <<-SQL
      ALTER TABLE #{Assignment.table_name}
        ADD CONSTRAINT fk_assignments_users
        FOREIGN KEY (user_id)
        REFERENCES #{User.table_name}(id)
    SQL
    execute <<-SQL
      ALTER TABLE #{Assignment.table_name}
        ADD CONSTRAINT fk_assignments_periods
        FOREIGN KEY (period_id)
        REFERENCES #{Period.table_name}(id)
    SQL
    execute <<-SQL
      ALTER TABLE #{Assignment.table_name}
        ADD CONSTRAINT fk_assignments_teams
        FOREIGN KEY (team_id)
        REFERENCES #{Team.table_name}(id)
    SQL
    execute <<-SQL
      ALTER TABLE #{Assignment.table_name}
        ADD CONSTRAINT fk_assignments_groups
        FOREIGN KEY (group_id)
        REFERENCES #{Group.table_name}(id)
    SQL
  end

  def down
    drop_table :assignments
  end
end
