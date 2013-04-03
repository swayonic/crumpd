class CreateGroupCoaches < ActiveRecord::Migration
  def up
    create_table :group_coaches do |t|
      t.integer :user_id, :null => false
      t.integer :group_id, :null => false
    end

    execute <<-SQL
      ALTER TABLE #{GroupCoach.table_name}
        ADD CONSTRAINT fk_coaches_users
        FOREIGN KEY (user_id)
        REFERENCES #{User.table_name}(id)
    SQL

    execute <<-SQL
      ALTER TABLE #{GroupCoach.table_name}
        ADD CONSTRAINT fk_coaches_groups
        FOREIGN KEY (group_id)
        REFERENCES #{Group.table_name}(id)
    SQL
  end

  def down
    drop_table :group_coaches
  end
end
