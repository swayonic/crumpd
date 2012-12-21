class HomeController < ApplicationController
	#	CAS railtie
	if Rails.env.production?
		before_filter RubyCAS::Filter, :except => :index
		before_filter RubyCAS::GatewayFilter, :only => :index
	end
	before_filter :cas_auth, :except => [:login, :do_login]

	def index
		if @user.is_admin
			@periods = Period.order('start DESC')
		else
			@periods = @user.periods
		end
	end

	def login
	end

	def do_login
		if newuser = User.find(params[:login][:id])
			session[:username] = newuser.id
			redirect_to :action => :index
		else
			flash.now[:alert] = "No user has the ID: #{params[:login][:id]}"
			render :login
		end
	end

	def logout
		if Rails.env.production?
			session[:username] = nil # Can't hurt
			RubyCAS::Filter.logout(self)
		else
			session[:username] = nil
			redirect_to :action => :index
		end
	end

	private
	def cas_auth
		@user = nil
		if Rails.env.production?
			@login_url = RubyCAS::Filter.login_url(self)
			if session[:cas_extra_attributes] and session[:cas_extra_attributes][:designation]
				if !@user = User.find_by_account_number(session[:cas_extra_attributes][:designation])
					# Create a temporary user with the given CAS attributes
					# Possibly, in the future, I might want to add this person to the database
					@user = User.new(
						:first_name => session[:cas_extra_attributes][:firstName],
						:last_name => session[:cas_extra_attributes][:lastName],
						:email => session[:cas_extra_attributes][:email],
						:account_number => session[:cas_extra_attributes][:designation])
				end
			end
		else #Development mode
			@login_url = '/login'
			@user = User.find(session[:username]) if session[:username]
		end

		if @user.nil?
			render 'shared/unauthorized'
			return false
		end
		return true
	end

	def admin_only
		if @user.nil? or !@user.is_admin
			render 'shared/unauthorized'
			return false
		end
		return true
	end

end
