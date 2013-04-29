class PledgesController < ApplicationController

  # GET /assignments/1/pledges
  def index
    if !@assignment = Assignment.find_by_id(params[:assignment_id])
      render 'shared/not_found'
      return
    end
    if !@assignment.can_view_pledges?(@cas_user)
      render 'shared/forbidden'
      return
    end

    @new_pledge = Pledge.new
    @new_pledge.assignment = @assignment
    all_breadcrumbs
  end

  # POST /assignment/1/pledges
  def create
    if !@assignment = Assignment.find_by_id(params[:assignment_id])
      render 'shared/not_found'
      return
    end
    if !@assignment.can_edit_pledges?(@cas_user)
      render 'shared/forbidden'
      return
    end

    @pledge = @assignment.pledges.build(params[:pledge])
    @pledge.name.strip!

    if @pledge.assignment.pledges.select{ |p| p.name == @pledge.name and p.frequency == @pledge.frequency}.count > 0
      flash.alert = "Cannot add another pledge with the name \"#{@pledge.name}\" as a #{Goal.freq_title @pledge.frequency} gift. Please choose a different name or remove the other pledge."
    elsif @pledge.save
      flash.notice = 'Pledge added'
    else
      flash.alert = 'Your pledge was improperly formatted and could not be saved.'
    end

    redirect_to :action => :index, :assignment_id => @pledge.assignment.id
  end

  # GET /pledges/1/toggle
  def toggle
    if !@pledge = Pledge.find_by_id(params[:id])
      render 'shared/not_found'
      return
    end
    if !@pledge.assignment.can_edit_pledges?(@cas_user)
      render 'shared/forbidden'
      return
    end

    @pledge.is_in_hand = !@pledge.is_in_hand

    if @pledge.save
      # Do nothing
    else
      flash.alert = 'Pledge not updated: an error occured while saving'
    end

    redirect_to :action => :index, :assignment_id => @pledge.assignment.id
  end

  # DELETE /pledges/1
  def destroy
    if !@pledge = Pledge.find_by_id(params[:id])
      render 'shared/not_found'
      return
    end
    if !@pledge.assignment.can_edit_pledges?(@cas_user)
      render 'shared/forbidden'
      return
    end

    @pledge.destroy

    redirect_to :action => :index, :assignment_id => @pledge.assignment.id
  end
  
  private
  # Adds breadcrumbs for all views
  def all_breadcrumbs
    add_breadcrumb(@assignment.period.name, url_for(@assignment.period), @assignment.period.can_view?(@cas_user), 'Coaching Period')
    if @assignment.group 
      add_breadcrumb(@assignment.group.display_name, url_for(@assignment.group), @assignment.group.can_view?(@cas_user), 'Coaching Group')
    elsif @assignment.team
      add_breadcrumb(@assignment.team.display_name, url_for(@assignment.team), @assignment.team.can_view?(@cas_user), 'Team')
    end
    add_breadcrumb(@assignment.user.display_name, url_for(@assignment), true, 'Assignment')
  end
end
