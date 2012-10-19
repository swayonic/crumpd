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
			ALTER TABLE pledges
				ADD CONSTRAINT fk_pledges_assignments
				FOREIGN KEY (assignment_id)
				REFERENCES assignments(id)
		SQL

		a = Assignment.first
		p = Pledge.new(:name => 'Mom', :amount => 100, :frequency => 12, :is_in_hand => true)
		p.assignment = a
		p.save
		p = Pledge.new(:name => 'Dad', :frequency => 12, :amount => 100)
		p.assignment = a
		p.save
  end

	def down
		drop_table :pledges
	end
end
