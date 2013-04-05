class AddTimeZoneToRegions < ActiveRecord::Migration
  def change
    add_column :regions, :time_zone, :string
  end
end
