class HomeController < ApplicationController
	#	CAS railtie
	if Rails.env.production?
		before_filter RubyCAS::Filter, :except => :index
		before_filter RubyCAS::GatewayFilter, :only => :index
	end
	before_filter :cas_auth, :except => [:login, :do_login, :datadump]

	def index
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

	# For testing of the data dump
	def datadump
		render :json => params.to_json
		return
	end

	private
	def cas_auth
		@user = nil
		if Rails.env.production?
			@login_url = RubyCAS::Filter.login_url(self)
			if session[:cas_extra_attributes] and session[:cas_extra_attributes][:designation]
				if !@user = User.find_by_account_number(session[:cas_extra_attributes][:designation])
					# Create a user with the given CAS attributes
					@user = User.new(
						:first_name => session[:cas_extra_attributes][:firstName],
						:last_name => session[:cas_extra_attributes][:lastName],
						:email => session[:cas_extra_attributes][:email],
						:account_number => session[:cas_extra_attributes][:designation])
					# Add this person to the database
					@user.save
					logger.info "Adding user from login attributes: #{@user.inspect}"
				else
					logger.info "Matched account number:'#{@user.account_number}' to user:'#{@user.display_name}'"
				end
			end
		else #Development mode
			@login_url = '/login'
			@user = User.find(session[:username]) if session[:username]
			logger.debug "Matched user_id:'#{session[:username]}' to user:'#{@user.display_name}'"
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
