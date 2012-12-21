class AssignmentsController < HomeController

	# GET /assignments/1
	def show
		@assignment = Assignment.find(params[:id])
		if !@assignment.can_view?(@user)
			render 'shared/unauthorized'
			return
		end
	end

	# GET /assignments/1/edit
	def edit
		@assignment = Assignment.find(params[:id])
		@new_goal = Goal.new
		if !@assignment.can_edit?(@user)
			render 'shared/unauthorized'
			return
		end
	end

	def update
		@assignment = Assignment.find(params[:id])
		if !@assignment.can_edit?(@user)
			render 'shared/unauthorized'
			return
		end

		valid = true

		params[:assignment][:team_id] = nil if params[:assignment][:team_id] == '0'
		params[:assignment][:group_id] = nil if params[:assignment][:group_id] == '0'

		for goal in @assignment.goals
			if params["remove_goal_#{goal.frequency}"] and params["remove_goal_#{goal.frequency}"] == '1'
				goal.destroy
			else
				params.select{|key, value| key == "goal_#{goal.frequency}"}.each do |key, value|
					goal.amount = Float(value[:amount])
				end
			end
		end

		if !params[:new_goal][:frequency].blank? and !params[:new_goal][:amount].blank?
			@new_goal = Goal.new(params[:new_goal])
			@new_goal.assignment = @assignment
			if !@new_goal.save
				flash.alert[:now] = 'Could not create new Goal'
			end
		end

		valid = false if !@assignment.update_attributes(params[:assignment])

		if valid
			redirect_to @assignment, notice: 'Assignment was successfully updated'
		else
			render action: 'edit'
		end
	end

	# POST /assignments/create_team
	def create_team
		assn = Assignment.new(params[:assignment])
		if !assn.can_edit?(@user)
			render 'shared/unauthorized'
			return
		end

		assns = assn.user.assignments.select{ |a| a.period and a.period.id == assn.team.period.id }

		if assns.count > 1
			throw "ERROR: No user should have two assignments in the same period"
		elsif assns.count == 1
			a = assns.first
			if a.team.nil?
				a.team = assn.team
				if a.save
					flash.notice = 'Member added'
				else
					flash.alert = 'Member not added: an error occured while saving.'
				end
			else
				if a.team.id == assn.team.id
					flash.notice = 'Member already exists'
				else
					flash.alert = 'Member not added: this user has been assigned to a different team.'
				end
			end
		else
			if assn.save
				flash.notice = 'Member added'
			else
				flash.alert = 'Member not added. An error occured while saving.'
			end
		end

		redirect_to assn.team
	end

	# DELETE /assignments/1/team
	def team
		assn = Assignment.find(params[:id])
		if !assn.can_edit?(@user)
			render 'shared/unauthorized'
			return
		end

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

	# POST /assignments/create_group
	def create_group
		assn = Assignment.new(params[:assignment])
		if !assn.can_edit?(@user)
			render 'shared/unauthorized'
			return
		end

		assns = assn.user.assignments.select{ |a| a.period and a.period.id == assn.group.period.id }

		if assns.count > 1
			throw "ERROR: No user should have two assignments in the same period"
		elsif assns.count == 1
			a = assns.first
			if a.group.nil?
				a.group = assn.group
				if a.save
					flash.notice = 'Member added'
				else
					flash.alert = 'Member not added: an error occured while saving.'
				end
			else
				if a.group.id == assn.group.id
					flash.notice = 'Member already exists'
				else
					flash.alert = 'Member not added: this user has been assigned to a different group.'
				end
			end
		else
			if assn.save
				flash.notice = 'Member added'
			else
				flash.alert = 'Member not added. An error occured while saving.'
			end
		end

		redirect_to assn.group
	end

	# DELETE /assignments/1/group
	def group
		assn = Assignment.find(params[:id])
		if !assn.can_edit?(@user)
			render 'shared/unauthorized'
			return
		end

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
