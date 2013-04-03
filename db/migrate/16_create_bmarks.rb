class CreateBmarks < ActiveRecord::Migration
  def up
    create_table :bmarks do |t|
      t.integer :period_id, :null => false
      t.datetime :date, :null => false
      t.integer :percentage, :null => false, :default => 100
    end

    execute <<-SQL
      ALTER TABLE #{Bmark.table_name}
        ADD CONSTRAINT fk_bmarks_periods
        FOREIGN KEY (period_id)
        REFERENCES #{Period.table_name}(id)
    SQL
  end

  def down
    drop_table :bmarks
  end
end
