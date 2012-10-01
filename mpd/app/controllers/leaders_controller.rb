class LeadersController < HomeController
	
	# POST /teams/1/leaders
	def create
		@team = Team.find(params[:team_id])
		@leader = @team.team_leaders.build(params[:team_leader])

		if @team.leaders.select{ |u| u.id == @leader.user_id}.count > 0
			notice = 'Leader already exists'
		elsif @leader.save
			notice = 'Leader added'
		else
			alert = 'Leader not added'
		end

		redirect_to @team
	end

	# DELETE /leaders/1?return=url
	def destroy
		@leader = TeamLeader.find(params[:id])
		@leader.destroy

		if params[:return]
			redirect_to params[:return]
		else
			redirect_to @leader.team
		end
	end

end
