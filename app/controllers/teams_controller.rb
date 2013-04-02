class TeamsController < HomeController
  
  # GET /teams/1
  def show
    if !@team = Team.find_by_id(params[:id])
      render 'shared/not_found'
      return
    end
    if !@team.can_view?(@cas_user)
      render 'shared/forbidden'
      return
    end

    @new_leader = TeamLeader.new
    @new_leader.team = @team
    
    @new_assn = Assignment.new
    @new_assn.team = @team
    @new_assn.period = @team.period

    member_breadcrumbs
  end

  # GET /teams/1/edit
  def edit
    if !@team = Team.find_by_id(params[:id])
      render 'shared/not_found'
      return
    end
    if !@team.can_edit?(@cas_user)
      render 'shared/forbidden'
      return
    end
    member_breadcrumbs
  end

  # POST /periods/1/teams
  def create
    if !@period = Period.find_by_id(params[:period_id])
      render 'shared/not_found'
      return
    end
    if !@period.can_edit?(@cas_user) or @period.keep_updated?
      render 'shared/forbidden'
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
    if !@team = Team.find_by_id(params[:id])
      render 'shared/not_found'
      return
    end
    if !@team.can_edit?(@cas_user)
      render 'shared/forbidden'
      return
    end

    if params[:team][:name]
      name = params[:team][:name].strip
      if name.blank?
        @team.name = nil
      else
        @team.name = name
      end
    end

    # Only update these if the period is not kept updated
    if !@team.period.keep_updated
      if params[:team][:city]
        city = params[:team][:city].strip
        if city.blank?
          @team.city = nil
        else
          @team.city = city
        end
      end
      if params[:team][:state]
        state = params[:team][:state].strip
        if state.blank?
          @team.state = nil
        else
          @team.state = state
        end
      end
      if params[:team][:country]
        country = params[:team][:country].strip
        if country.blank?
          @team.country = nil
        else
          @team.country = country
        end
      end
      if params[:team][:continent]
        continent = params[:team][:continent].strip
        if continent.blank?
          @team.continent = nil
        else
          @team.continent = continent
        end
      end  
    end
    
    if @team.save
      redirect_to @team, notice: 'Team was successfully updated.'
    else
      member_breadcrumbs
      render action: "edit"
    end
  end

  # DELETE /teams/1
  def destroy
    if !@team = Team.find_by_id(params[:id])
      render 'shared/not_found'
      return
    end
    if !@team.period.can_edit?(@cas_user) or @team.period.keep_updated?
      render 'shared/forbidden'
      return
    end

    if @team.assignments.count > 0
      flash.alert = 'Cannot delete this team'
    elsif  @team.destroy
      flash.notice = 'Team deleted'
    else
      flash.alert = 'Failed to delete team'
    end
    
    redirect_to @team.period
  end

  # GET /teams/1/list
  def list
    if !@team = Team.find_by_id(params[:id])
      render 'shared/not_found'
      return
    end
    if !@team.can_view_list?(@cas_user)
      render 'shared/forbidden'
      return
    end

    @period = @team.period
    @assignments = @team.assignments
    @fields = params[:fields] || Hash.new

    if params[:commit] == 'Download Excel'
      @title = "#{@period.name} - #{@team.display_name}"
      render 'assignments/list.xls', :content_type => 'application/xls'
      return
    end

    member_breadcrumbs
    render :layout => 'list'
  end

  private
  # Adds breadcrumbs for all member views
  def member_breadcrumbs
    add_breadcrumb(@team.period.name, url_for(@team.period), @team.period.can_view?(@cas_user), 'Coaching Period')
    add_breadcrumb(@team.display_name, url_for(@team), 'Team')
  end

end
