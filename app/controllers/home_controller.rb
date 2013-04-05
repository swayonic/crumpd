class HomeController < ApplicationController

  # GET /
	def index
	end

  # GET /login
	def login
	end

  # POST /do_login
	def do_login
		if newuser = User.find_by_id(params[:login][:id])
			session[:user_id] = newuser.id
			redirect_to :action => :index
		else
			flash.now[:alert] = 'No user found'
			render :login
		end
	end

  # GET /logout
	def logout
		if Rails.env.production?
			RubyCAS::Filter.logout(self)
		else
			session[:user_id] = nil
			session[:sudo_id] = nil
			redirect_to :action => :index
		end
	end

  # POST /full_update
	def full_update
		if !@cas_user.is_admin?
			render 'shared/unauthorized'
			return
		end

	  # Manually perform system-wide data update
		Sitrack.update_all
		redirect_to :back
	end

	def not_found
		render 'shared/not_found'
	end

end
