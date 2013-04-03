class CreateUsers < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string :guid
      t.string :account_number
      t.string :first_name
      t.string :last_name
      t.string :preferred_name
      t.string :phone
      t.string :email
      t.boolean :is_admin, :null => false, :default => false
    end
  end

  def down
    drop_table :users
  end
end
