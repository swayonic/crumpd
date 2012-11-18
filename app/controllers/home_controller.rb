class HomeController < ApplicationController
	#	CAS railtie
	#before_filter RubyCAS::Filter
	before_filter :fake_cas, :except => [:login, :do_login]

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
			@sso = User.find(session[:username])
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
