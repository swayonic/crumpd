class SitrackController < HomeController
	skip_before_filter :cas_auth
	
	# POST /sitrack/dump
	def dump
		periods = params[:periods].split('+') if params[:periods]
		users = params[:users].split('+') if params[:users]

		assignments = Array.new

		assignments = period_query(periods)
		people = user_query(users)
		regions = region_query

		render :json => {
			:assignments => assignments,
			:people => people,
			:regions => regions
			}.to_json
	end

	private

	def user_query(list)
		return nil if !list

		if !list.kind_of?(Array)
			tmp = list
			list = Array.new
			list << tmp
		end

		return nil if list.empty?

		ActiveRecord::Base.silence_auto_explain do
	  	# no automatic EXPLAIN is triggered here
			return Sitrack.find_by_sql(
				'SELECT p.accountNo, p.firstName, p.lastName, p.preferredName, s.email, s.mobilePhone, s.homePhone, s.otherPhone ' +
				'FROM ministry_person AS p ' +
				'LEFT JOIN ministry_staff AS s ON p.personID = s.person_id ' +
				"WHERE p.accountNo IN (#{list.map{|u| "'#{u}'"}.join(',')})"
				)
		end
	end

	def period_query(list)
		return nil if !list

		if !list.kind_of?(Array)
			tmp = list
			list = Array.new
			list << tmp
		end

		return nil if list.empty?

		split_list = Array.new
		for p in list
			if p =~ /^(\w+)_(\d{4})$/
				split_list << [$1, $2]
			end
		end

		ActiveRecord::Base.silence_auto_explain do
	  	# no automatic EXPLAIN is triggered here
			return Sitrack.find_by_sql(
				'SELECT t.caringRegion, t.asgYear, t.status, t.internType, t.tenure, t.asgTeam, t.asgCity, t.asgState, t.asgCountry, t.asgContinent, p.accountNo, p.firstName, p.lastName, p.preferredName, m.coachName, m.monthlyGoal, m.oneTimeGoal, s.email, s.mobilePhone, s.homePhone, s.otherPhone ' +
				'FROM sitrack_tracking AS t ' +
				'JOIN hr_si_applications AS a ON a.applicationID = t.application_id ' +
				'JOIN ministry_person AS p ON a.fk_personID = p.personID ' +
				# Might not be able to grab these tables, it's OK
				'LEFT JOIN ministry_staff AS s ON a.fk_personID = s.person_id ' +
				'LEFT JOIN sitrack_mpd AS m on m.application_id = a.applicationID ' +
				'WHERE p.accountNo IS NOT NULL AND (' +
				split_list.map{|p| "(caringRegion='#{p[0]}' AND asgYear='#{p[1]}-#{p[1]+1}')"}.join(' OR ') +
				')'
				)
		end
	end

	def region_query
		ActiveRecord::Base.silence_auto_explain do
	  	# no automatic EXPLAIN is triggered here
			return Sitrack.find_by_sql('SELECT caringRegion FROM sitrack_tracking WHERE caringRegion IS NOT NULL GROUP BY caringRegion').map{|s| s[:caringRegion]}
		end
	end

end

