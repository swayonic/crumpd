class CreateGroups < ActiveRecord::Migration
  def up
    create_table :groups do |t|
      t.string :name # not necessary
			t.references :period
    end

		execute <<-SQL
			ALTER TABLE groups
				ADD CONSTRAINT fk_groups_periods
				FOREIGN KEY (period_id)
				REFERENCES periods(id)
		SQL

		g = Group.new(
			:name => 'Group 1'
			)
		g.period = Period.first
		g.save

  end

	def down
		drop_table :groups
	end
end
