class HomeController < ApplicationController
	#	CAS railtie
	if Rails.env.production?
		before_filter RubyCAS::Filter, :except => :index
		before_filter RubyCAS::GatewayFilter, :only => :index
	end
	before_filter :sso_auth, :except => [:login, :do_login]

	def index
		if @sso.is_admin
			@periods = Period.order('start DESC')
		else
			@periods = @sso.periods
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
	def sso_auth
		@sso = nil
		if Rails.env.production?
			@login_url = RubyCAS::Filter.login_url(self)
			#TODO
#			@sso = User.find_by_account_no(session[:cas_extra_attributes][:designation]) if session[:cas_extra_attributes] and session[:cas_extra_attributes][:designation]
			@sso = User.first if session[:cas_extra_attributes] and session[:cas_extra_attributes][:designation]
		else #Development mode
			@login_url = '/login'
			@sso = User.find(session[:username]) if session[:username]
		end

		if @sso.nil?
			render 'shared/unauthorized'
			return false
		end
		return true
	end

	def admin_only
		if @sso.nil? or !@sso.is_admin
			render 'shared/unauthorized'
			return false
		end
		return true
	end

end
