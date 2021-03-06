class UsersController < ApplicationController

  if Rails.env.development?
    # Used in the development login screen
    skip_before_filter :authorize, :only => :autocomplete
  end

  # GET /users/1
  def show
    if !@user = User.find_by_id(params[:id])
      render 'shared/not_found'
      return
    end
    if !@user.can_view?(current_user)
      render 'shared/forbidden'
      return
    end
  end

  # GET /users/1/edit
  def edit
    if !@user = User.find_by_id(params[:id])
      render 'shared/not_found'
      return
    end
    if !@user.can_edit?(current_user)
      render 'shared/forbidden'
      return
    end
  end

  # PUT /users/1
  def update
    if !@user = User.find_by_id(params[:id])
      render 'shared/not_found'
      return
    end
    if !@user.can_edit?(current_user)
      render 'shared/forbidden'
      return
    end

    # Only change allowed fields

    @user.time_zone = params[:user][:time_zone]

    if !@user.gets_updated?
      @user.preferred_name = params[:user][:preferred_name]
      @user.last_name = params[:user][:last_name]
      @user.phone = params[:user][:phone]
      @user.email = params[:user][:email]
    end

    if current_user.is_admin?
      if params[:real_user][:name].blank?
        @user.real_id = nil
      else
        @user.real_id = params[:user][:real_id]
      end
    end

    if @user.save
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render action: "edit"
    end
  end

  # DELETE /users/1
  def destroy
    if !@user = User.find_by_id(params[:id])
      render 'shared/not_found'
      return
    end
    if !current_user.is_admin?
      render 'shared/forbidden'
      return
    end

    @user.destroy

    redirect_to :controller => :home, :action => :index
  end

  # GET /users/1/confirm
  def confirm
    if !@user = User.find_by_id(params[:id])
      render 'shared/not_found'
      return
    end
    @continue_path = params[:continue]
  end

  # GET /users/autocomplete
  def autocomplete
    results = Array.new

    # TODO
    # Do I need to filter?
    # This is slow
    for user in User.all
      if user.account_number and !user.account_number.blank?
        string = "#{user.display_name} (#{user.account_number})"
      else
        string = user.display_name
      end
      if string.downcase =~ /#{params[:term].downcase}/
        results << {:id => user.id, :label => string, :value => user.display_name}
      end
    end

    render :json => results.sort_by{|r| r[:label]}[0..9].to_json
  end

  # POST /users/1/toggle_admin
  def toggle_admin
    if !user = User.find_by_id(params[:id])
      render 'shared/not_found'
      return
    end

    if !current_user.is_admin?
      render 'shared/forbidden'
      return
    end

    user.is_admin = !user.is_admin
    user.save

    redirect_to :user, :notice => 'User updated.'
  end

  # GET /users/1/sudo
  def sudo
    if !user = User.find_by_id(params[:id])
      render 'shared/not_found'
      return
    end

    true_user = sudo_user || current_user
    if !user.can_sudo?(true_user)
      render 'shared/forbidden'
      return
    end

    session[:sudo_id] = user.id

    redirect_to user
  end

  # GET /users/unsudo
  def unsudo
    session[:sudo_id] = nil
    redirect_to :back
  end

end
