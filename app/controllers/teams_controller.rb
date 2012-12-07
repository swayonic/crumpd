class TeamsController < HomeController
  
  # GET /teams/1
  def show
    @team = Team.find(params[:id])
		if !@team.can_view?(@sso)
			render 'shared/unauthorized'
			return
		end

		@new_leader = TeamLeader.new
		@new_leader.team = @team
		
		@new_assn = Assignment.new
		@new_assn.team = @team
  end

  # GET /teams/1/edit
  def edit
    @team = Team.find(params[:id])
		if !@team.can_edit?(@sso)
			render 'shared/unauthorized'
			return
		end
  end

  # POST /periods/1/teams
  def create
		@period = Period.find(params[:period_id])
		if !@period.can_edit?(@sso)
			render 'shared/unauthorized'
			return
		end

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
		if !@team.can_edit?(@sso)
			render 'shared/unauthorized'
			return
		end
		
		if @team.update_attributes(params[:team])
			redirect_to @team, notice: 'Team was successfully updated.'
		else
			render action: "edit"
		end
  end

  # DELETE /teams/1
  def destroy
    @team = Team.find(params[:id])
		if !@team.period.can_edit?(@sso)
			render 'shared/unauthorized'
			return
		end

    @team.destroy
		
		redirect_to @team.period
  end

	# GET /teams/1/list
	def list
		@team = Team.find(params[:id])
		if !@team.can_view_list?(@sso)
			render 'shared/unauthorized'
			return
		end

		@period = @team.period
		@assignments = @team.assignments
		@fields = params[:fields] || Hash.new
		@sort = params[:sort] || Hash.new
		
		if params[:commit] == 'Download Excel'
			@title = "#{@period.name} - #{@team.name} (Team)"
			render "list/show.xls", :content_type => "application/xls"
			return
		end
	end

end
