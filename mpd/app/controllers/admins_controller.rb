class AdminsController < HomeController
	
	# POST /periods/1/admins
	def create
		@period = Period.find(params[:period_id])
		@admin = @period.period_admins.build(params[:period_admin])

		if @admin.save
			notice = 'Admin created'
		else
			alert = 'Admin not created'
		end

		redirect_to @period
	end

	# DELETE /admins/1?return=url
	def destroy
		@admin = PeriodAdmin.find(params[:id])
		@admin.destroy

		if params[:return]
			redirect_to params[:return]
		else
			redirect_to @admin.period
		end
	end

end
