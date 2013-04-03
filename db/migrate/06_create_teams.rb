class CreateTeams < ActiveRecord::Migration
  def up
    create_table :teams do |t|
      t.integer :period_id, :null => false
      t.string :name # Set by tool

      # Sitrack data
      t.integer :sitrack_id
      t.string :city
      t.string :state
      t.string :country
      t.string :continent
    end

    execute <<-SQL
      ALTER TABLE #{Team.table_name}
        ADD CONSTRAINT fk_teams_periods
        FOREIGN KEY (period_id)
        REFERENCES #{Period.table_name}(id)
    SQL
  end

  def down
    drop_table :teams
  end
end
