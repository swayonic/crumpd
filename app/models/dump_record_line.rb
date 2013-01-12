class DumpRecord < ActiveRecord::Base
  attr_accessible :dump_record_id, :period_id, :assignment_count, :team_count, :group_count

	belongs_to :dump_record
	belongs_to :period

end
