class CreateGroups < ActiveRecord::Migration
  def up
    create_table :groups do |t|
      t.integer :period_id, :null => false
      t.string :name
      # NOTE: This is not authoritative, you still have to go in and
      # add the coach manually through crumpd
      t.string :coach_name
    end

    execute <<-SQL
      ALTER TABLE #{Group.table_name}
        ADD CONSTRAINT fk_groups_periods
        FOREIGN KEY (period_id)
        REFERENCES #{Period.table_name}(id)
    SQL
  end

  def down
    drop_table :groups
  end
end
