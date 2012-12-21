class ListController < HomeController
  
  # GET /list/1(/:uri)(.:format)
  def show
    @period = Period.find(params[:id])
		if !@period.can_view?(@user)
			render 'shared/unauthorized'
			return
		end

		@list_title = "#{@period.name} (Period)"
		@assignments = @period.assignments
  end

end
