class AdminsController < HomeController
	
	# POST /periods/1/admins
	def create
		@period = Period.find(params[:period_id])
		if !@period.can_edit_admins?(@cas_user)
			render 'shared/unauthorized'
			return
		end

		@admin = @period.period_admins.build(params[:period_admin])

		if @admin.user.nil?
			flash.alert = 'No user found'
		elsif @period.admins.select{ |u| u.id == @admin.user_id}.count > 0
			flash.notice = 'Admin already exists'
		elsif @admin.save
			flash.notice = 'Admin added'
		else
			flash.alert = 'Admin not added'
		end

		redirect_to @period
	end

	# DELETE /admins/1?return=url
	def destroy
		@admin = PeriodAdmin.find(params[:id])
		if !@admin.period.can_edit_admins?(@cas_user)
			render 'shared/unauthorized'
			return
		end

		@admin.destroy

		if params[:return]
			redirect_to params[:return]
		else
			redirect_to @admin.period
		end
	end

end
