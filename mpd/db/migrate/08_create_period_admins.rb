class CreatePeriodAdmins < ActiveRecord::Migration
  def up
    create_table :period_admins do |t|
			t.integer :user_id, :null => false
			t.integer :period_id, :null => false
    end
		
		execute <<-SQL
			ALTER TABLE period_admins
				ADD CONSTRAINT fk_admins_users
				FOREIGN KEY (user_id)
				REFERENCES users(id)
		SQL
		execute <<-SQL
			ALTER TABLE period_admins
				ADD CONSTRAINT fk_admins_periods
				FOREIGN KEY (period_id)
				REFERENCES periods(id)
		SQL

		a = PeriodAdmin.new
		a.user = User.find_by_first_name("Regina")
		a.period = Period.first
		a.save

  end

	def down
		drop_table :period_admins
	end
end
