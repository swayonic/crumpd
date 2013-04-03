class CreateTeamLeaders < ActiveRecord::Migration
  def up
    create_table :team_leaders do |t|
      t.integer :user_id, :null => false
      t.integer :team_id, :null => false
    end

    execute <<-SQL
      ALTER TABLE #{TeamLeader.table_name}
        ADD CONSTRAINT fk_leaders_users
        FOREIGN KEY (user_id)
        REFERENCES #{User.table_name}(id)
    SQL
    execute <<-SQL
      ALTER TABLE #{TeamLeader.table_name}
        ADD CONSTRAINT fk_leaders_teams
        FOREIGN KEY (team_id)
        REFERENCES #{Team.table_name}(id)
    SQL
  end

  def down
    drop_table :team_leaders
  end
end
