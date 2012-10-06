class GroupMembersController < HomeController
  
	# POST /groups/1/group_members
	def create
		group = Group.find(params[:group_id])
		user = User.find(params[:user][:user_id])

		assns = user.assignments.select{ |a| a.period and a.period.id == group.period.id }

		if assns.count > 1
			throw "ERROR: No user should have two assignments in the same period"
		elsif assns.count == 1
			a = assns.first
			if a.group.nil?
				a.group = group
				if a.save
					flash.notice = 'Member added'
				else
					flash.alert = 'Member not added: an error occured while saving.'
				end
			else
				if a.group.id == group.id
					flash.notice = 'Member already exists'
				else
					flash.alert = 'Member not added: this user has been assigned to a different coaching group.'
				end
			end
		else
			a = Assignment.new
			a.group = group
			a.user = user
			if a.save
				flash.notice = 'Member added'
			else
				flash.alert = 'Member not added. An error occured while saving.'
			end
		end

		redirect_to group
	end

	# DELETE /group_members/1
	def destroy
		assn = Assignment.find(params[:id])

		group = assn.group

		assn.group = nil

		if assn.team.nil?
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

		redirect_to group
	end

end
