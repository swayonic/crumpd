class TeamsController < HomeController
  
  # GET /teams/1
  def show
    @team = Team.find(params[:id])

		@new_leader = TeamLeader.new
		@new_leader.team = @team
  end

  # GET /periods/1/teams/new
  def new
		@period = Period.find(params[:period_id])
    @team = @period.teams.build
  end

  # GET /teams/1/edit
  def edit
    @team = Team.find(params[:id])
  end

  # POST /periods/1/teams
  def create
		@period = Period.find(params[:period_id])
    @team = @period.teams.build(params[:team])
		
		if @team.save
			redirect_to @team, notice: 'Team was successfully created.'
		else
			render action: "new"
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
