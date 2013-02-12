class GroupsController < HomeController
  
  # GET /groups/1
  def show
    @group = Group.find(params[:id])
		if !@group.can_view?(@cas_user)
			render 'shared/unauthorized'
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
    @group = Group.find(params[:id])
		if !@group.can_edit?(@cas_user)
			render 'shared/unauthorized'
			return
		end
		member_breadcrumbs
  end

  # POST /periods/1/groups
  def create
    @period = Period.find(params[:period_id])
		if !@period.can_edit?(@cas_user)
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
		if !@group.can_edit?(@cas_user)
			render 'shared/unauthorized'
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
    @group = Group.find(params[:id])
		if !@group.period.can_edit?(@cas_user)
			render 'shared/unauthorized'
			return
		end

    @group.destroy
		
		redirect_to period_url(@group.period)
  end
	
	# DELETE /group_coaches/1
	def destroy_coach
		@coach = GroupCoach.find(params[:id])
		if !@coach.group.can_edit?(@cas_user)
			render 'shared/unauthorized'
			return
		end

		@coach.destroy

		render :text => 'Group Coach destroyed.'
	end

	# GET /groups/1/list
	def list
		@group = Group.find(params[:id])
		if !@group.can_view_list?(@cas_user)
			render 'shared/unauthorized'
			return
		end

		@period = @group.period
		@assignments = @group.assignments
		@fields = params[:fields] || Hash.new
		
		if params[:commit] == 'Download Excel'
			@title = "#{@period.name} - #{@group.display_name}"
			render 'assignments/list.xls', :content_type => 'application/xls'
			return
		end
		
		member_breadcrumbs
	end
	
	private
	# Adds breadcrumbs for all member views
	def member_breadcrumbs
		add_breadcrumb(@group.period.name, url_for(@group.period), @group.period.can_view?(@cas_user), 'Coaching Period')
		add_breadcrumb(@group.display_name, url_for(@group), true, 'Coaching Group')
	end


end
