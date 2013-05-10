class ApplicationController < ActionController::Base
  protect_from_forgery

  ### Authorization

  if Rails.env.production?
    before_filter RubyCAS::Filter, :except => :index
    before_filter RubyCAS::GatewayFilter, :only => :index
  end
  before_filter :authorize, :except => [:login, :do_login]

  ### SSL Issues

  if Rails.env.production?
    def default_url_options(options = {})
      { :only_path => false, :protocol => 'https' }
    end
  end

  ### Time zone

  around_filter :user_time_zone, if: :current_user

  ### User methods
  # current_user: usually what you want
  # original_user: the User that is actually logged in
  #   (only set if current_user.real_user exists)
  # sudo_user: the hidden user who is sudoing to become current_user
  #   (only set if session[:sudo_id] is set)

  helper_method :current_user
  def current_user
    return @sudoee if @sudoee
    return @cas_user.real_user if @cas_user and @cas_user.real_user
    return @cas_user
  end

  helper_method :original_user
  def original_user
    return nil unless @cas_user and @cas_user.real_user
    return @cas_user
  end

  helper_method :sudo_user
  def sudo_user
    return nil unless @cas_user and @sudoee
    return @cas_user.real_user if @cas_user and @cas_user.real_user
    return @cas_user
  end

  ### Breadcrumbs

  def add_breadcrumb(text, link, allowed = true, title = nil)
    @breadcrumbs = Array.new if @breadcrumbs.nil?
    @breadcrumbs << {
      :text => text,
      :link => link,
      :allowed => allowed,
      :title => title
      }
  end

  private

  def authorize
    # Set login path
    if Rails.env.production?
      @login_path = RubyCAS::Filter.login_url(self)
    else
      @login_path = '/login'
    end

    # Set @cas_user from CAS params

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
            # Notify Airbrake, as this shouldn't happen often
            Airbrake.notify Exception.new("Added user ##{@cas_user.id} from login attributes: #{session[:cas_extra_attributes]}")
          end
        end
        if @cas_user and (@cas_user.last_login.nil? or (Time.now - @cas_user.last_login) > 20.minutes)
          # Set last_login if it has never been set or is older than 20 minutes ago
          @cas_user.last_login = DateTime.now
          @cas_user.save
        end
      end
    else # Development mode
      if session[:user_id] and @cas_user = User.find_by_id(session[:user_id])
        @cas_user.last_login = DateTime.now
        @cas_user.save
      end
    end

    if @cas_user.nil?
      render 'shared/unauthorized'
      return false
    end

    # Set @sudoee if necessary

    if session[:sudo_id]
      if sudoee = User.find_by_id(session[:sudo_id]) and sudoee.can_sudo?(current_user)
        sudoee.is_admin = false # You can't sudo into admin privileges
        @sudoee = sudoee
      end
    end

    return true
  end

  def user_time_zone(&block)
    Time.use_zone(current_user.time_zone, &block)
  end

end
