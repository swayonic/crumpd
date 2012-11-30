module ListHelper

	def list_header_sort_link(title, id = nil)
		id ||= title

		direction = (id == @sort[:column] && @sort[:direction] == 'asc') ? 'desc' : 'asc'
		render :partial => 'list/header_link', :locals => {:title => title, :id => id, :direction => direction}
	end
	
	# Creates the array of data to be presented
	def build_list_data(assignments)
		data = Array.new
		sort = 0
		for a in assignments.sort_by{|a| [a.user.last_name, a.user.first_name]}
			line = Array.new
			report = a.latest_report

			line << a.user.display_name
			
			for g in @goals
				if @fields["#{g.frequency}_goal"] == '1'
					sort = line.size if @sort[:column] == "#{g.frequency}_goal"
					line << a.goal_total(g.frequency)
				end
				if @fields["#{g.frequency}_inhand_pct"] == '1'
					sort = line.size if @sort[:column] == "#{g.frequency}_inhand_pct"
					line << a.goal_inhand_pct(g.frequency) 
				end
				if @fields["#{g.frequency}_inhand_amt"] == '1'
					sort = line.size if @sort[:column] == "#{g.frequency}_inhand_amt"
					line << a.goal_inhand(g.frequency)
				end
				if @fields["#{g.frequency}_pledged_pct"] == '1'
					sort = line.size if @sort[:column] == "#{g.frequency}_pledged_pct"
					line << a.goal_pledged_pct(g.frequency)
				end
				if @fields["#{g.frequency}_pledged_amt"] == '1'
					sort = line.size if @sort[:column] == "#{g.frequency}_pledged_amt"
					line << a.goal_pledged(g.frequency)
				end
			end
			for rf in @period.report_fields
				if @fields["field_#{rf.id}"] == '1'
					sort = line.size if @sort[:column] == "field_#{rf.id}"
					if !report.nil? and l = report.field_lines.find_by_report_field_id(rf.id)
						line << l.value
					else
						line << ''
					end
				end
			end

			data << line
		end

		data = data.sort_by{|line| line[sort]} if sort > 0
		data = data.reverse if @sort[:direction] == 'desc'
		return data
	end

end
