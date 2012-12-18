module ListHelper

	def list_header_sort_link(title, id = nil)
		id ||= title

		sort = (id == @sort[:column])
		direction = (id == @sort[:column] && @sort[:direction] == 'asc') ? 'desc' : 'asc'
		render :partial => 'list/header_link', :locals => {:title => title, :id => id, :sort => sort, :direction => direction}
	end
	
	# Creates the array of data to be presented
	def build_list_data(assignments)
		data = Array.new
		sort = 0
		for a in assignments.sort_by{|a| [a.user.last_name, a.user.first_name]}
			line = Array.new
			report = a.latest_report

			line << a.user.display_name
			if a.latest_report.nil?
				line << 'None'
			else
				line << a.latest_report.created_at
			end
			
			for g in @goals
				if @fields["#{g.frequency}_goal"] == '1'
					sort = line.size if @sort[:column] == "#{g.frequency}_goal"
					line << a.goal_amt(g.frequency)
				end
				if @fields["#{g.frequency}_inhand_pct"] == '1'
					sort = line.size if @sort[:column] == "#{g.frequency}_inhand_pct"
					if report
						if l = report.goal_lines.find_by_frequency(g.frequency)
							line << Goal.pct(l.inhand, a.goal_amt(g.frequency))
						else
							line << 0
						end
					else
						line << nil
					end
				end
				if @fields["#{g.frequency}_inhand_amt"] == '1'
					sort = line.size if @sort[:column] == "#{g.frequency}_inhand_amt"
					if report
						if l = report.goal_lines.find_by_frequency(g.frequency)
							line << l.inhand
						else
							line << 0
						end
					else
						line << nil
					end
				end
				if @fields["#{g.frequency}_pledged_pct"] == '1'
					sort = line.size if @sort[:column] == "#{g.frequency}_pledged_pct"
					if report
						if l = report.goal_lines.find_by_frequency(g.frequency)
							line << Goal.pct(l.pledged, a.goal_amt(g.frequency))
						else
							line << 0
						end
					else
						line << nil
					end
				end
				if @fields["#{g.frequency}_pledged_amt"] == '1'
					sort = line.size if @sort[:column] == "#{g.frequency}_pledged_amt"
					if report
						if l = report.goal_lines.find_by_frequency(g.frequency)
							line << l.pledged
						else
							line << 0
						end
					else
						line << nil
					end
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

		#Deal with nil's in the data
		data = data.sort{|a,b| (a[sort] and b[sort]) ? a[sort] <=> b[sort] : (a[sort] ? 1 : -1)} if sort > 0
		data = data.reverse if @sort[:direction] == 'desc'
		return data
	end

end
