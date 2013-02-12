class SitrackController < HomeController
	#TODO: Skip only if it's a local request?
	skip_before_filter :cas_auth
	
	# POST /sitrack/dump
	def dump
	end

	# GET /sitrack/user?account_number=1
	def user
		result = nil
		if params[:account_number] =~ /^(\d{9})(S|)$/
			num = "#{$1}#{$2}"
			result = Sitrack.find_by_sql(
				'SELECT p.accountNo, p.firstName, p.lastName, p.preferredName, s.email, s.mobilePhone, s.homePhone, s.otherPhone ' +
				'FROM ministry_person AS p ' +
				'LEFT JOIN ministry_staff AS s ON p.personID = s.person_id ' +
				"WHERE p.accountNo = '#{num}'"
				).first
		end

		if result.nil?
			render :json => {:found => false}.to_json
		else
			phone = result[:mobilePhone] || result[:homePhone] || result[:otherPhone]
			render :json => {
				:found => true,
				:account_number => result[:accountNo],
				:first_name => result[:firstName],
				:last_name => result[:lastName],
				:preferred_name => result[:preferredName],
				:email => result[:email],
				:phone => phone}.to_json
		end
	end

end
