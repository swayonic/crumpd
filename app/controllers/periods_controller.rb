class PeriodsController < HomeController

  # GET /periods/1
  def show
    @period = Period.find(params[:id])
		if !@period.can_view?(@sso)
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
		if !@period.can_view_fields?(@sso)
			render 'shared/unauthorized'
			return
		end
	end

	# POST /periods/1/update_fields
	def update_fields
		@period = Period.find(params[:id])
		if !@period.can_edit_fields?(@sso)
			render 'shared/unauthorized'
			return
		end

		flash.notice = params.inspect

		redirect_to :action => :show_fields, :id => params[:id]
	end

end
