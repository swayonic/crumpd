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

end
