class CreateReports < ActiveRecord::Migration
  def up
    create_table :reports do |t|
      t.integer :assignment_id
      t.decimal :monthly_inhand
      t.decimal :new_monthly_amt
      t.integer :new_monthly_count
      t.decimal :new_monthly_pledged
      t.decimal :onetime_inhand
      t.decimal :new_onetime_amt
      t.integer :new_onetime_count
      t.decimal :onetime_pledged
      t.decimal :account_balance
      t.integer :num_contacts
      t.integer :new_referrals
      t.integer :num_phone_dials
      t.integer :num_phone_convos
      t.float :phone_hours
      t.integer :num_precall_letters
      t.integer :num_support_letters
      t.float :letter_hours
      t.float :mpd_hours
      t.boolean :had_coach_convo
      t.text :prayer_requests

      t.timestamps
    end
		
		execute <<-SQL
			ALTER TABLE reports
				ADD CONSTRAINT fk_reports_assignments
				FOREIGN KEY (assignment_id)
				REFERENCES assignments(id)
		SQL

		r = Report.new
		r.assignment = Assignment.first
		r.save

  end

	def down
		drop_table :reports
	end
end
