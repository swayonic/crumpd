class CreateAssignments < ActiveRecord::Migration
  def up
    create_table :assignments do |t|
			t.references :user
			t.references :team
			t.references :group
      t.decimal :monthly_goal
      t.decimal :one_time_goal
    end
		
		execute <<-SQL
			ALTER TABLE assignments
				ADD CONSTRAINT fk_assignments_users
				FOREIGN KEY (user_id)
				REFERENCES users(id)
		SQL
		execute <<-SQL
			ALTER TABLE assignments
				ADD CONSTRAINT fk_assignments_teams
				FOREIGN KEY (team_id)
				REFERENCES teams(id)
		SQL
		execute <<-SQL
			ALTER TABLE assignments
				ADD CONSTRAINT fk_assignments_groups
				FOREIGN KEY (group_id)
				REFERENCES groups(id)
		SQL

		a = Assignment.new(:monthly_goal => 2080, :one_time_goal => 17282)
		a.user = User.find_by_last_name("Yeager")
		a.team = Team.first
		a.group = Group.first
		a.save

  end

	def down
		drop_table :assignments
	end
end
