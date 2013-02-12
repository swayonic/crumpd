class HomeController < ApplicationController
	#	CAS railtie
	if Rails.env.production?
		before_filter RubyCAS::Filter, :except => :index
		before_filter RubyCAS::GatewayFilter, :only => :index
	end
	before_filter :cas_auth, :except => [:login, :do_login]
	helper_method :add_breadcrumb

	def index
		render :json => SitrackQuery::Query.update_all
	end

	def login
	end

	def do_login
		if newuser = User.find_by_id(params[:login][:id])
			session[:username] = newuser.id
			redirect_to :action => :index
		else
			flash.now[:alert] = 'No user found'
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
		@cas_user = nil
		if Rails.env.production?
			@login_url = RubyCAS::Filter.login_url(self)
			if session[:cas_extra_attributes] and session[:cas_extra_attributes][:emplid]
				account_number = User.cleanup_account_number(session[:cas_extra_attributes][:emplid])
				if account_number and !@cas_user = User.find_by_account_number(account_number)
					# Create a user with the given CAS attributes
					@cas_user = User.new(
						:first_name => session[:cas_extra_attributes][:firstName],
						:last_name => session[:cas_extra_attributes][:lastName],
						:email => session[:cas_extra_attributes][:email],
						:account_number => account_number)
					# Add this person to the database
					@cas_user.save
					logger.info "Adding user from login attributes: #{@cas_user.inspect}"
				end
			end
		else #Development mode
			@login_url = '/login'
			@cas_user = User.find_by_id(session[:username]) if session[:username]
		end

		if @cas_user.nil?
			render 'shared/unauthorized'
			return false
		end
		return true
	end

	def admin_only
		if @cas_user.nil? or !@cas_user.is_admin
			render 'shared/unauthorized'
			return false
		end
		return true
	end

	def add_breadcrumb(text, link, allowed = true, title = nil)
		@breadcrumbs = Array.new if @breadcrumbs.nil?
		@breadcrumbs << {
			:text => text,
			:link => link,
			:allowed => allowed,
			:title => title
			}
	end

end
