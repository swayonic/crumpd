class CreatePeriods < ActiveRecord::Migration
  def up
    create_table :periods do |t|
      t.string :name, :null => false
      t.date :start
      t.date :end
    end

		p = Period.new(
			:name => "STINT 2012-2013",
			:start => "2012/05/01",
			:end => "2012/08/01"
			)
		p.save
  end

	def down
		drop_table :periods
	end
end
