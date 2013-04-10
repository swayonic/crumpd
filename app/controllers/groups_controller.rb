class GroupsController < ApplicationController

  # GET /groups/1
  def show
    if !@group = Group.find_by_id(params[:id])
      render 'shared/not_found'
      return
    end
    if !@group.can_view?(@cas_user)
      render 'shared/forbidden'
      return
    end

    @new_coach = GroupCoach.new
    @new_coach.group = @group
    
    @new_assn = Assignment.new
    @new_assn.group = @group
    @new_assn.period = @group.period

    member_breadcrumbs
  end

  # GET /groups/1/edit
  def edit
    if !@group = Group.find_by_id(params[:id])
      render 'shared/not_found'
      return
    end
    if !@group.can_edit?(@cas_user)
      render 'shared/forbidden'
      return
    end
    member_breadcrumbs
  end

  # POST /periods/1/groups
  def create
    if !@period = Period.find_by_id(params[:period_id])
      render 'shared/not_found'
      return
    end
    if !@period.can_edit?(@cas_user) or @period.keep_updated?
      render 'shared/forbidden'
      return
    end

    @group = @period.groups.build(params[:group])
    
    if @group.name.strip.empty?
      redirect_to @period, alert: 'Cannot create a group without a name'
    elsif @group.save
      redirect_to @group, notice: 'Group was successfully created.'
    else
      redirect_to @period, alert: 'Cannot create group: an error occured while saving'
    end
  end

  # PUT /groups/1
  def update
    if !@group = Group.find_by_id(params[:id])
      render 'shared/not_found'
      return
    end
    if !@group.can_edit?(@cas_user)
      render 'shared/forbidden'
      return
    end

    if params[:group][:name]
      name = params[:group][:name].strip
      if name.blank?
        @group.name = nil
      else
        @group.name = name
      end
    end

    # Only update these if the period is not kept updated
    if !@group.period.keep_updated
      if params[:group][:coach_name]
        coach_name = params[:group][:coach_name].strip
        if coach_name.blank?
          @group.coach_name = nil
        else
          @group.coach_name = coach_name
        end
      end    
    end

    if @group.save
      redirect_to @group, notice: 'Group was successfully updated.'
    else
      member_breadcrumbs
      render action: "edit"
    end
  end

  # DELETE /groups/1
  def destroy
    if !@group = Group.find_by_id(params[:id])
      render 'shared/not_found'
      return
    end
    if !@group.period.can_edit?(@cas_user) or @group.period.keep_updated?
      render 'shared/forbidden'
      return
    end

    if @group.assignments.count > 0
      flash.alert = 'Cannot delete this group'
    elsif @group.destroy
      flash.notice = 'Group deleted'
    else
      flash.alert = 'Failed to delete group'
    end
    
    redirect_to @group.period
  end
  
  # GET /groups/1/list
  def list
    if !@group = Group.find_by_id(params[:id])
      render 'shared/not_found'
      return
    end
    if !@group.can_view_list?(@cas_user)
      render 'shared/forbidden'
      return
    end

    @period = @group.period
    @assignments = @group.assignments.active
    @fields = params[:fields] || Hash.new

    if params[:commit] == 'Download Excel'
      @title = "#{@period.name} - #{@group.display_name}"
      render 'assignments/list.xls', :content_type => 'application/xls'
      return
    end

    member_breadcrumbs
    render :layout => 'list'
  end

  private
  # Adds breadcrumbs for all member views
  def member_breadcrumbs
    add_breadcrumb(@group.period.name, url_for(@group.period), @group.period.can_view?(@cas_user), 'Coaching Period')
    add_breadcrumb(@group.display_name, url_for(@group), true, 'Coaching Group')
  end


end
