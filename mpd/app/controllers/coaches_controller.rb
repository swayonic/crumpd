class CoachesController < HomeController
	
	# POST /groups/1/coaches
	def create
		@group = Group.find(params[:group_id])
		@coach = @group.group_coaches.build(params[:group_coach])

		if @coach.save
			notice = 'Coach added'
		else
			alert = 'Coach not added'
		end

		redirect_to @group
	end

	# DELETE /coaches/1?return=url
	def destroy
		@coach = GroupCoach.find(params[:id])
		@coach.destroy

		if params[:return]
			redirect_to params[:return]
		else
			redirect_to @coach.group
		end
	end

end
