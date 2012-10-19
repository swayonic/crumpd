class CreateAssignments < ActiveRecord::Migration
  def up
    create_table :assignments do |t|
			t.integer :user_id, :null => false
			t.integer :period_id, :null => false
			t.integer :team_id
			t.integer :group_id
    end
		
		execute <<-SQL
			ALTER TABLE assignments
				ADD CONSTRAINT fk_assignments_users
				FOREIGN KEY (user_id)
				REFERENCES users(id)
		SQL
		execute <<-SQL
			ALTER TABLE assignments
				ADD CONSTRAINT fk_assignments_periods
				FOREIGN KEY (period_id)
				REFERENCES periods(id)
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

		a = Assignment.new
		a.user = User.first
		a.period = Period.first
		a.team = Team.first
		a.group = Group.first
		a.save
		a = Assignment.new
		a.user = User.find_by_last_name('Tayne')
		a.period = Period.first
		a.team = Team.first
		a.save
		a = Assignment.new
		a.user = User.find_by_last_name('Couts')
		a.period = Period.first
		a.team = Team.first
		a.save
		a = Assignment.new
		a.user = User.find_by_last_name('Nystrom')
		a.period = Period.first
		a.team = Team.first
		a.save
		a = Assignment.new
		a.user = User.find_by_last_name('Sanders')
		a.period = Period.first
		a.team = Team.find(2)
		a.group = Group.first
		a.save

  end

	def down
		drop_table :assignments
	end
end
