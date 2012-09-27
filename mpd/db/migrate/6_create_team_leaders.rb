class CreateTeamLeaders < ActiveRecord::Migration
  def up
    create_table :team_leaders do |t|
			t.references :user
			t.references :team
    end

		execute <<-SQL
			ALTER TABLE team_leaders
				ADD CONSTRAINT fk_leaders_users
				FOREIGN KEY (user_id)
				REFERENCES users(id)
		SQL
		execute <<-SQL
			ALTER TABLE team_leaders
				ADD CONSTRAINT fk_leaders_teams
				FOREIGN KEY (team_id)
				REFERENCES teams(id)
		SQL

		l = TeamLeader.new
		l.user = User.find_by_last_name("Tayne")
		l.team = Team.first
		l.save

  end

	def down
		drop_table :team_leaders
	end
end