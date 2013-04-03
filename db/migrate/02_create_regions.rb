class CreateRegions < ActiveRecord::Migration
  def up
    create_table :regions do |t|
      t.string :name, :null => false
      t.string :title
    end
  end

  def down
    drop_table :regions
  end
end
