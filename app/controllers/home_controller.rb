class HomeController < ApplicationController
  #  CAS railtie
  if Rails.env.production?
    before_filter RubyCAS::Filter, :except => :index
    before_filter RubyCAS::GatewayFilter, :only => :index
  end
  before_filter :authorize, :except => [:login, :do_login]
  helper_method :add_breadcrumb

  def index
  end

  def login
  end

  def do_login
    if newuser = User.find_by_id(params[:login][:id])
      session[:user_id] = newuser.id
      redirect_to :action => :index
    else
      flash.now[:alert] = 'No user found'
      render :login
    end
  end

  def logout
    if Rails.env.production?
      RubyCAS::Filter.logout(self)
    else
      session[:user_id] = nil
      redirect_to :action => :index
    end
  end

  # Manually perform system-wide data update
  def full_update
    if !@cas_user.is_admin?
      render 'shared/unauthorized'
      return
    end

    Sitrack.update_all
    redirect_to :back
  end

  def not_found
    render 'shared/not_found'
  end

  def cas_user
    return @cas_user if @cas_user # Only set once

    if Rails.env.production?
      if session[:cas_extra_attributes] and guid = session[:cas_extra_attributes][:ssoGuid]
        if !@cas_user = User.find_by_guid(guid)
          # Check to see if we've been given a valid account number
          account_number = User.cleanup_account_number(session[:cas_extra_attributes][:designation]) || User.cleanup_account_number(session[:cas_extra_attributes][:emplid]) || nil

          if account_number and @cas_user = User.find_by_account_number(account_number)
            # Associate guid with this user
            @cas_user.guid = guid
            @cas_user.save
            
            logger.info "Trusting user and associating guid #{guid} with user ##{@cas_user.id}"
          else
            # Create a user with the given CAS attributes
            @cas_user = User.new(
              :guid => guid,
              :account_number => account_number, # may be nil
              :first_name => session[:cas_extra_attributes][:firstName],
              :last_name => session[:cas_extra_attributes][:lastName],
              :email => session[:cas_extra_attributes][:email]
              )
            # Add this person to the database
            @cas_user.save
            logger.info "Added user ##{@cas_user.id} from login attributes: #{session[:cas_extra_attributes]}"
          end
        end
      end
    else # Development mode
      @cas_user = User.find_by_id(session[:user_id]) if session[:user_id]
    end

    return @cas_user
  end
  helper_method :cas_user

  def sudoer
    return @sudoer if @sudoer # Only set once

    if session[:sudo_id]
      if sudoee = User.find_by_id(session[:sudo_id]) and sudoee.can_sudo?(@cas_user)
        @sudoer = @cas_user
        @cas_user = sudoee
        @cas_user.is_admin = false # You can't sudo into admin privileges
      end
    end

    return @sudoer
  end
  helper_method :sudoer

  def true_user
    sudoer || cas_user
  end
  helper_method :true_user

  private

  def authorize
    if Rails.env.production?
      @login_path = RubyCAS::Filter.login_url(self)
    else
      @login_path = '/login'
    end

    if cas_user.nil?
      render 'shared/unauthorized'
      return false
    end

    sudoer

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
