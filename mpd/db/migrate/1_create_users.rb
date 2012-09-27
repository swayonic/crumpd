class CreateUsers < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string :first_name, :null => false
      t.string :last_name, :null => false
      t.string :account_number
      t.string :email
      t.string :phone
      t.boolean :is_admin, :null => false, :default => false
    end

		User.new(:first_name => "Luke",	:last_name => "Yeager",	:account_number => "0578812",	:email => "luke.yeager@cru.org", :is_admin => true).save
		User.new(:first_name => "Regina",	:last_name => "Clark").save
		User.new(:first_name => "James",	:last_name => "Wood").save
		User.new(:first_name => "Ethan",	:last_name => "Tayne").save
  end

	def down
		drop_table :users
	end
end
