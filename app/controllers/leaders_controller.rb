class LeadersController < HomeController
	
	# POST /teams/1/leaders
	def create
		@team = Team.find(params[:team_id])
		if !@team.can_view?(@cas_user)
			render 'shared/unauthorized'
			return
		end

		@leader = @team.team_leaders.build(params[:team_leader])

		if @leader.user.nil?
			flash.alert = 'No user found'
		elsif @team.leaders.select{ |u| u.id == @leader.user_id}.count > 0
			flash.notice = 'Leader already exists'
		elsif @leader.save
			flash.notice = 'Leader added'
		else
			flash.alert = 'Leader not added'
		end

		redirect_to @team
	end

	# DELETE /leaders/1?return=url
	def destroy
		@leader = TeamLeader.find(params[:id])
		if !@leader.team.can_edit?(@cas_user)
			render 'shared/unauthorized'
			return
		end
		@leader.destroy

		if params[:return]
			redirect_to params[:return]
		else
			redirect_to @leader.team
		end
	end

end
