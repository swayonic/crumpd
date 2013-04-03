class CreatePledges < ActiveRecord::Migration
  def up
    create_table :pledges do |t|
      t.integer :assignment_id, :null => false
      t.string :name, :null => false
      t.decimal :amount, :null => false
      t.integer :frequency, :null => false
      t.boolean :is_in_hand, :null => false, :default => false
    end

    execute <<-SQL
      ALTER TABLE #{Pledge.table_name}
        ADD CONSTRAINT fk_pledges_assignments
        FOREIGN KEY (assignment_id)
        REFERENCES #{Assignment.table_name}(id)
    SQL
  end

  def down
    drop_table :pledges
  end
end
