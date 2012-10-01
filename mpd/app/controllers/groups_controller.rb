class GroupsController < HomeController
  
  # GET /groups/1
  def show
    @group = Group.find(params[:id])
  end

  # GET /periods/1/groups/new
  def new
		@period = Period.find(params[:period_id])
		@group = @period.groups.build
  end

  # GET /groups/1/edit
  def edit
    @group = Group.find(params[:id])
  end

  # POST /periods/1/groups
  def create
    @period = Period.find(params[:period_id])
		@group = @period.groups.build(params[:group])
		
		if @group.save
			redirect_to @group, notice: 'Group was successfully created.'
		else
			render action: "new"
		end
  end

  # PUT /groups/1
  def update
    @group = Group.find(params[:id])
		
		if @group.update_attributes(params[:group])
			redirect_to @group, notice: 'Group was successfully updated.'
		else
			render action: "edit"
		end
  end

  # DELETE /groups/1
  def destroy
    @group = Group.find(params[:id])
    @group.destroy
		
		redirect_to period_url(@group.period)
  end
	
	# DELETE /group_coaches/1
	def destroy_coach
		@coach = GroupCoach.find(params[:id])
		@coach.destroy

		render :text => 'Group Coach destroyed.'
	end

end
