class SitrackController < HomeController
	skip_before_filter :cas_auth
	
	# POST /sitrack/dump
	def dump
		periods_in = params[:periods].split('+') if params[:periods]
		users_in = params[:users].split('+') if params[:users]

		periods_out = Hash.new
		for p in periods_in
			periods_out[p] = period_query(p)
		end
		users_out = user_query(users_in)
		regions = region_query

		render :json => {
			:periods => periods_out,
			:users => users_out,
			:regions => regions
			}.to_json
	end

	private

	# list is an array of account numbers
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

	# periods is a string like "RR_2012"
	def period_query(period)
		if period =~ /^(\w+)_(\d{4})$/
			region = $1
			year = Integer($2)
		else
			return nil
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
				"WHERE t.caringRegion='#{region}' AND t.asgYear='#{year}-#{year+1}' AND p.accountNo IS NOT NULL"
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

