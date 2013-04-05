class LeadersController < ApplicationController

  # POST /teams/1/leaders
  def create
    if !@team = Team.find_by_id(params[:team_id])
      render 'shared/not_found'
      return
    end
    if !@team.can_view?(@cas_user)
      render 'shared/forbidden'
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
    if !@leader = TeamLeader.find_by_id(params[:id])
      render 'shared/not_found'
      return
    end
    if !@leader.team.can_edit?(@cas_user)
      render 'shared/forbidden'
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
