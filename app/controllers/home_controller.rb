class HomeController < ApplicationController
	#	CAS railtie
	if ENV['RAILS_ENV'] == 'production'
		before_filter RubyCAS::Filter, :except => :index
		before_filter :fake_cas, :except => [:login, :do_login]
	else
		before_filter :fake_cas, :except => [:login, :do_login]
	end

	def index
		@controller = self
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
		if ENV['RAILS_ENV'] == 'production'
			RubyCAS::Filter.logout(self)
		end
		session[:username] = nil
		redirect_to :action => :index
	end

	def unauthorized
	end

	private
	def fake_cas
		if session[:username] == nil
			@sso = nil
			render 'shared/unauthorized'
			return false
		else
			# TODO Fix
			#@sso = User.find(session[:username])
			@sso = User.first
			return true
		end
	end

	def admin_only
		if @sso.nil? or !@sso.is_admin
			render :partial => 'shared/unauthorized'
			return false
		end
		return true
	end

end
