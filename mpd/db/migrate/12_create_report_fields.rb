class CreateReportFields < ActiveRecord::Migration
  def up
    create_table :report_fields do |t|
			t.integer :period_id, :null => false
			t.integer :list_index, :null => false, :default => 1
			t.string :name, :null => false
			t.string :field_type, :null => false
			t.boolean :required, :null => false, :default => false
			t.string :description
			t.boolean :active, :null => false, :default => true
    end
		
		execute <<-SQL
			ALTER TABLE report_fields
				ADD CONSTRAINT fk_report_fields_periods
				FOREIGN KEY (period_id)
				REFERENCES periods(id)
		SQL

		p = Period.first
		p.report_fields.new(
			:name => 'Account Balance',
			:field_type => 'D',
			:description => 'Current account balance')
		p.report_fields.new(
			:name => 'Prayer requests',
			:field_type => 'T')
		p.report_fields.new(
			:name => 'MPD Hours',
			:field_type => 'I',
			:description => 'The total amount of time spent on MPD',
			:required => true)
		p.save
  end

	def down
		drop_table :report_fields
	end
end
