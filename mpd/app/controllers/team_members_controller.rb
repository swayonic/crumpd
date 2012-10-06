class TeamMembersController < HomeController
  
	# POST /teams/1/team_members
	def create
		team = Team.find(params[:team_id])
		user = User.find(params[:user][:user_id])

		assns = user.assignments.select{ |a| a.period and a.period.id == team.period.id }

		if assns.count > 1
			throw "ERROR: No user should have two assignments in the same period"
		elsif assns.count == 1
			a = assns.first
			if a.team.nil?
				a.team = team
				if a.save
					flash.notice = 'Member added'
				else
					flash.alert = 'Member not added: an error occured while saving.'
				end
			else
				if a.team.id == team.id
					flash.notice = 'Member already exists'
				else
					flash.alert = 'Member not added: this user has been assigned to a different team.'
				end
			end
		else
			a = Assignment.new
			a.team = team
			a.user = user
			if a.save
				flash.notice = 'Member added'
			else
				flash.alert = 'Member not added. An error occured while saving.'
			end
		end

		redirect_to team
	end

	# DELETE /team_members/1
	def destroy
		assn = Assignment.find(params[:id])

		team = assn.team

		assn.team = nil

		if assn.group.nil?
			if assn.destroy
				flash.notice = 'Member removed'
			else
				flash.alert = 'Member not removed: error while deleting assignment'
			end
		else
			if assn.save
				flash.notice = 'Member removed'
			else
				flash.alert = 'Member not removed: error while updating'
			end
		end

		redirect_to team
	end

end
