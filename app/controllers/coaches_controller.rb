class CoachesController < HomeController
	
	# POST /groups/1/coaches
	def create
		@group = Group.find(params[:group_id])
		if !@group.can_edit_coaches?(@cas_user)
			render 'shared/unauthorized'
			return
		end

		@coach = @group.group_coaches.build(params[:group_coach])

		if @coach.user.nil?
			flash.alert = 'No user found'
		elsif @group.coaches.select{ |u| u.id == @coach.user_id }.count > 0
			flash.notice = 'Coach already exists'
		elsif @coach.save
			flash.notice = 'Coach added'
		else
			flash.alert = 'Coach not added'
		end

		redirect_to @group
	end

	# DELETE /coaches/1?return=url
	def destroy
		@coach = GroupCoach.find(params[:id])
		if !@coach.group.can_edit_coaches?(@cas_user)
			render 'shared/unauthorized'
			return
		end

		@coach.destroy

		if params[:return]
			redirect_to params[:return]
		else
			redirect_to @coach.group
		end
	end

end
