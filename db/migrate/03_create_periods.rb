class CreatePeriods < ActiveRecord::Migration
  def up
    create_table :periods do |t|
      t.integer :region_id, :null => false
      t.integer :year, :null => false
      t.boolean :keep_updated, :null => false, :default => true
      t.datetime :last_updated
    end

    execute <<-SQL
      ALTER TABLE #{Period.table_name}
        ADD CONSTRAINT fk_periods_regions
        FOREIGN KEY (region_id)
        REFERENCES #{Region.table_name}(id)
    SQL
  end

  def down
    drop_table :periods
  end
end
