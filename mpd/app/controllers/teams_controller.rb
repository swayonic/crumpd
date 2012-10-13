class TeamsController < HomeController
  
  # GET /teams/1
  def show
    @team = Team.find(params[:id])

		@new_leader = TeamLeader.new
		@new_leader.team = @team
		
		@new_assn = Assignment.new
		@new_assn.team = @team
  end

  # GET /teams/1/edit
  def edit
    @team = Team.find(params[:id])
  end

  # POST /periods/1/teams
  def create
		@period = Period.find(params[:period_id])
    @team = @period.teams.build(params[:team])
	
		if @team.name.strip.empty?
			redirect_to @period, alert: 'Cannot create a team without a name'
		elsif @team.save
			redirect_to @team, notice: 'Team was successfully created.'
		else
			redirect_to @period, alert: 'Cannot create team: an error occured while saving'
		end
  end

  # PUT /teams/1
  def update
		@team = Team.find(params[:id])
		
		if @team.update_attributes(params[:team])
			redirect_to @team, notice: 'Team was successfully updated.'
		else
			render action: "edit"
		end
  end

  # DELETE /teams/1
  def destroy
    @team = Team.find(params[:id])
    @team.destroy
		
		redirect_to period_url(@team.period)
  end

end
