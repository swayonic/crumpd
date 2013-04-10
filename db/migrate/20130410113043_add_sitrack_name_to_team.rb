class AddSitrackNameToTeam < ActiveRecord::Migration
  def change
    add_column :teams, :sitrack_name, :string
  end
end
