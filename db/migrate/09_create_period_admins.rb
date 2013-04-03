class CreatePeriodAdmins < ActiveRecord::Migration
  def up
    create_table :period_admins do |t|
      t.integer :user_id, :null => false
      t.integer :period_id, :null => false
    end

    execute <<-SQL
      ALTER TABLE #{PeriodAdmin.table_name}
        ADD CONSTRAINT fk_admins_users
        FOREIGN KEY (user_id)
        REFERENCES #{User.table_name}(id)
    SQL
    execute <<-SQL
      ALTER TABLE #{PeriodAdmin.table_name}
        ADD CONSTRAINT fk_admins_periods
        FOREIGN KEY (period_id)
        REFERENCES #{Period.table_name}(id)
    SQL
  end

  def down
    drop_table :period_admins
  end
end
