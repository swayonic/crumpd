class CreateTeams < ActiveRecord::Migration
  def up
    create_table :teams do |t|
      t.string :name, :null => false
			t.references :period
      t.date :start
      t.date :end
    end

		execute <<-SQL
			ALTER TABLE teams
				ADD CONSTRAINT fk_teams_periods
				FOREIGN KEY (period_id)
				REFERENCES periods(id)
		SQL

		t = Team.new(
			:name => "EA YZ",
			:start => "2012/08/01",
			:end => "2013/07/01")
		t.period = Period.first
		t.save
		t = Team.new(
			:name => "EA NJ",
			:start => "2012/08/01",
			:end => "2013/07/01")
		t.period = Period.first
		t.save

  end

	def down
		drop_table :teams
	end
end
