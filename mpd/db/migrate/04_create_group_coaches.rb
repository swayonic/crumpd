class CreateGroupCoaches < ActiveRecord::Migration
  def up
    create_table :group_coaches do |t|
			t.integer :user_id, :null => false
			t.integer :group_id, :null => false
    end

		execute <<-SQL
			ALTER TABLE group_coaches
				ADD CONSTRAINT fk_coaches_users
				FOREIGN KEY (user_id)
				REFERENCES users(id)
		SQL

		execute <<-SQL
			ALTER TABLE group_coaches
				ADD CONSTRAINT fk_coaches_groups
				FOREIGN KEY (group_id)
				REFERENCES groups(id)
		SQL

		c = GroupCoach.new
		c.user = User.find_by_last_name("Wood")
		c.group = Group.first
		c.save

  end

	def down
		drop_table :group_coaches
	end
end
