class PeriodsController < HomeController

  # GET /periods/1
  def show
		#TODO authentication
    @period = Period.find(params[:id])

		@new_group = Group.new
		@new_group.period = @period
		
		@new_team = Team.new
		@new_team.period = @period
		
		@new_admin = PeriodAdmin.new
		@new_admin.period = @period
  end

end
