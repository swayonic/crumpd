class AddRealIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :real_id, :integer
  end
end
