class CreateReportFields < ActiveRecord::Migration
  def up
    create_table :report_fields do |t|
      t.integer :period_id, :null => false
      t.integer :list_index, :null => false, :default => 1
      t.string :name, :null => false
      t.string :field_type, :null => false, :default => 'I'
      t.boolean :required, :null => false, :default => false
      t.string :description
      t.boolean :active, :null => false, :default => true
    end

    execute <<-SQL
      ALTER TABLE #{ReportField.table_name}
        ADD CONSTRAINT fk_report_fields_periods
        FOREIGN KEY (period_id)
        REFERENCES #{Period.table_name}(id)
    SQL
  end

  def down
    drop_table :report_fields
  end
end
