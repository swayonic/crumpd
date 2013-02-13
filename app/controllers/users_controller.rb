class UsersController < HomeController
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
		if !@user.can_view?(@cas_user)
			render 'shared/unauthorized'
			return
		end
  end

  # GET /users/1/edit
  def edit
    if !@user = User.find_by_id(params[:id])
			render 'shared/not_found'
			return
		end
		if !@user.can_edit?(@cas_user)
			render 'shared/unauthorized'
			return
		end
  end

  # PUT /users/1
  def update
    if !@user = User.find_by_id(params[:id])
			render 'shared/not_found'
			return
		end
		if !@user.can_edit?(@cas_user)
			render 'shared/unauthorized'
			return
		end
		
		if @user.update_attributes(params[:user])
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
		if !@user.can_edit?(@cas_user)
			render 'shared/unauthorized'
			return
		end

    @user.destroy

		redirect_to users_url # DNE
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
			string = "#{user.display_name} (#{user.account_number})"
			if string.downcase =~ /#{params[:term].downcase}/
				results << {:id => user.id, :label => string, :value => user.display_name}
			end
		end

		render :json => results.to_json
	end

	# POST /users/1/toggle_admin
	def toggle_admin
		if !user = User.find_by_id(params[:id])
			render 'shared/not_found'
			return
		end

		if !@cas_user.is_admin?
			render 'shared/unauthorized'
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

		if !user.can_sudo?(true_user)
			render 'shared/unauthorized'
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
