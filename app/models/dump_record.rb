class DumpRecord < ActiveRecord::Base
  attr_accessible :status, :assignments_count, :regions_count, :created_at, :updated_at

end
