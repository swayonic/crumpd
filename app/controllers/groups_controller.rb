class GroupsController < HomeController
  
  # GET /groups/1
  def show
    @group = Group.find(params[:id])
		if !@group.can_view?(@sso)
			render 'shared/unauthorized'
			return
		end


		@new_coach = GroupCoach.new
		@new_coach.group = @group
		
		@new_assn = Assignment.new
		@new_assn.group = @group
  end

  # GET /groups/1/edit
  def edit
    @group = Group.find(params[:id])
		if !@group.can_edit?(@sso)
			render 'shared/unauthorized'
			return
		end

  end

  # POST /periods/1/groups
  def create
    @period = Period.find(params[:period_id])
		if !@period.can_edit?(@sso)
			render 'shared/unauthorized'
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
    @group = Group.find(params[:id])
		if !@group.can_edit?(@sso)
			render 'shared/unauthorized'
			return
		end

		if @group.update_attributes(params[:group])
			redirect_to @group, notice: 'Group was successfully updated.'
		else
			render action: "edit"
		end
  end

  # DELETE /groups/1
  def destroy
    @group = Group.find(params[:id])
		if !@group.period.can_edit?(@sso)
			render 'shared/unauthorized'
			return
		end

    @group.destroy
		
		redirect_to period_url(@group.period)
  end
	
	# DELETE /group_coaches/1
	def destroy_coach
		@coach = GroupCoach.find(params[:id])
		if !@coach.group.can_edit?(@sso)
			render 'shared/unauthorized'
			return
		end

		@coach.destroy

		render :text => 'Group Coach destroyed.'
	end

	# GET /groups/1/list
	def list
		@group = Group.find(params[:id])
		if !@group.can_view_list?(@sso)
			render 'shared/unauthorized'
			return
		end

		@period = @group.period
		@fields = params[:fields] || Hash.new
		@sort = params[:sort] || Hash.new
	end

end
