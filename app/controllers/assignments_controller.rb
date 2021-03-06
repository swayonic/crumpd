class AssignmentsController < ApplicationController

  # GET /assignments/1
  def show
    if !@assignment = Assignment.find_by_id(params[:id])
      render 'shared/not_found'
      return
    end
    if !@assignment.can_view?(current_user)
      render 'shared/forbidden'
      return
    end
    member_breadcrumbs
  end

  # GET /assignments/1/edit
  def edit
    if !@assignment = Assignment.find_by_id(params[:id])
      render 'shared/not_found'
      return
    end
    if !@assignment.can_edit?(current_user)
      render 'shared/forbidden'
      return
    end

    @new_goal = Goal.new
    member_breadcrumbs
  end

  # PUT /assignments/1
  def update
    if !@assignment = Assignment.find_by_id(params[:id])
      render 'shared/not_found'
      return
    end
    if !@assignment.can_edit?(current_user)
      render 'shared/forbidden'
      return
    end

    valid = true

    params[:assignment][:team_id] = nil if params[:assignment][:team_id] == '0'
    params[:assignment][:group_id] = nil if params[:assignment][:group_id] == '0'

    for goal in @assignment.goals
      if params["remove_goal_#{goal.frequency}"] and params["remove_goal_#{goal.frequency}"] == '1'
        goal.destroy
      else
        params.select{|key, value| key == "goal_#{goal.frequency}"}.each do |key, value|
          goal.amount = Float(value[:amount])
        end
      end
    end

    if !params[:new_goal][:frequency].blank? and !params[:new_goal][:amount].blank?
      if params[:new_goal][:frequency] =~ /^\s*(\d+)\s*$/
        freq = $1
        if goal = @assignment.goals.find_by_frequency(freq)
          goal.amount = params[:new_goal][:amount]
        else
          goal = @assignment.goals.build(
            :frequency => freq,
            :amount => params[:new_goal][:amount]
            )
        end
        if !goal.save
          flash.alert = 'Could not create new Goal'
          valid = false
        end
      end
    end

    valid = false if valid and !@assignment.update_attributes(params[:assignment])

    if valid
      redirect_to @assignment, notice: 'Assignment updated'
    else
      member_breadcrumbs
      render action: 'edit'
    end
  end

  # POST /assignments/create
  def create
    assn = Assignment.new(params[:assignment])
    if !assn.can_edit?(current_user)
      render 'shared/forbidden'
      return
    end

    continue = params[:continue] || request.referrer

    if params[:add_member].nil?
      flash.alert = 'Member not added'
      redirect_to continue
      return
    end

    # Adding a new user
    if params[:add_member][:new] == '1'
      if account_number = User.cleanup_account_number(params[:add_member][:account_number])
        if !old_user = User.find_by_account_number(account_number)
          if new_user = Sitrack.find_user(account_number)
            if new_user.save
              redirect_to(
                :controller => :users,
                :action => :confirm,
                :id => new_user.id,
                :continue => url_for(
                  :action => :create,
                  'assignment[period_id]' => assn.period_id,
                  'assignment[team_id]' => assn.team_id,
                  'assignment[group_id]' => assn.group_id,
                  'add_member[new]' => '0',
                  'add_member[user_id]' => new_user.id,
                  'continue' => request.referrer
                  )
                )
              return
            else
              flash.alert = 'Failed to save the new user'
            end
          else
            flash.alert = "No user found for account number: #{params[:add_member][:account_number]}"
          end
        else
          user_id = old_user.id
          # Fall through to existing user
        end
      else
        flash.notice = 'Member not added'
      end

      unless user_id # Some error occurred
        redirect_to continue
        return
      end

    # Adding an existing user
    else
      user_id = $1 if params[:add_member][:user_id] =~ /^(\d+)$/
    end

    if user_id.nil?
      flash.alert = 'No member selected'
    elsif !User.find_by_id(user_id)
      flash.alert = 'No user found'
    else
      assn.user_id = user_id
    end

    if assn.user_id.nil?
      redirect_to continue
      return
    end

    # Update group/team
    assns = assn.user.assignments.select{ |a| a.period and a.period.id == assn.period.id }
    if assns.count > 1
      throw "ERROR: No user should have two assignments in the same period"
    elsif assns.count == 1
      a = assns.first
      
      #NOTE: This doesn't warn the user if they switch someone's group or team
      a.team = assn.team if assn.team
      a.group = assn.group if assn.group

      assn = a
    end

    if assn.status.blank?
      # This should only happen in test regions, so we just want to make it visible
      assn.status = 'placed'
    end

    if assn.save
      flash.notice = 'Member added'
    else
      flash.alert = 'Member not added. An error occured while saving.'
    end

    redirect_to continue
  end

  # DELETE /assignments/1?delete=[group|team]
  def destroy
    if !assn = Assignment.find_by_id(params[:id])
      render 'shared/not_found'
      return
    end
    if assn.period.keep_updated? or !assn.can_edit?(current_user)
      render 'shared/forbidden'
      return
    end

    if !params[:delete]
      u = assn.user
      if assn.destroy
        flash.notice = 'Assignment destroyed.'
        redirect_to u
      else
        flash.alert = 'Failed to delete assignment.'
        redirect_to assn
      end
      return
    elsif params[:delete] == 'group'
      assn.group = nil
    elsif params[:delete] == 'team'
      assn.team = nil
    else
      flash.alert = 'Nothing to delete'
      redirect_to :back
      return
    end

    if assn.group.nil? and assn.team.nil?
      # Don't delete the assignment automatically
    end

    if assn.save
      flash.notice = 'Member removed'
    else
      flash.alert = 'Member not removed: error while updating'
    end

    redirect_to :back
  end

  private
  # Adds breadcrumbs for all member views
  def member_breadcrumbs
    add_breadcrumb(@assignment.period.name, url_for(@assignment.period), @assignment.period.can_view?(current_user), 'Coaching Period')
    if @assignment.group 
      add_breadcrumb(@assignment.group.display_name, url_for(@assignment.group), @assignment.group.can_view?(current_user), 'Coaching Group')
    elsif @assignment.team
      add_breadcrumb(@assignment.team.display_name, url_for(@assignment.team), @assignment.team.can_view?(current_user), 'Team')
    end
    add_breadcrumb(@assignment.user.display_name, url_for(@assignment), true, 'Assignment')
  end

end
