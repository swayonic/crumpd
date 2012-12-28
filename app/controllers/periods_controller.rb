class PeriodsController < HomeController

  # GET /periods/1
  def show
    @period = Period.find(params[:id])
		if !@period.can_view?(@user)
			render 'shared/unauthorized'
			return
		end

		@new_group = Group.new
		@new_group.period = @period
		
		@new_team = Team.new
		@new_team.period = @period
		
		@new_admin = PeriodAdmin.new
		@new_admin.period = @period
  end

	# GET /periods/1/show_fields
	def show_fields
		@period = Period.find(params[:id])
		if !@period.can_view?(@user)
			render 'shared/unauthorized'
			return
		end
	end

	# POST /periods/1/update_fields
	def update_fields
		@period = Period.find(params[:id])
		if !@period.can_edit?(@user)
			render 'shared/unauthorized'
			return
		end

		for field in @period.report_fields
			# TODO: sanitize input
			id = "field_#{field.id}"
			if params[id]
				params[id].delete('remove')
				field.update_attributes(params[id])
			end
		end

		redirect_to :action => :show_fields, :id => params[:id]
	end

	# GET /periods/1/list
	def list
		@period = Period.find(params[:id])
		if !@period.can_view?(@user)
			render 'shared/unauthorized'
			return
		end

		@assignments = @period.assignments
		@fields = params[:fields] || Hash.new

		if params[:commit] == 'Download Excel'
			@title = "#{@period.name} Complete List"
			render "list/show.xls", :content_type => "application/xls"
			return
		end
	end

end
