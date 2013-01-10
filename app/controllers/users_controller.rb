class UsersController < HomeController
	if Rails.env.development?
		# Used in the development login screen
		skip_before_filter :cas_auth, :only => :autocomplete
	end

  # GET /users/1
  def show
    @user = User.find(params[:id])
		if !@user.can_view?(@user)
			render 'shared/unauthorized'
			return
		end
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
		if !@user.can_edit?(@user)
			render 'shared/unauthorized'
			return
		end
  end

  # POST /users
  def create
    @user = User.new(params[:user])
		
		if @user.save
			redirect_to @user, notice: 'User was successfully created.'
		else
			render action: "new"
		end
  end

  # PUT /users/1
  def update
    @user = User.find(params[:id])
		if !@user.can_edit?(@user)
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
    @user = User.find(params[:id])
		if !@user.can_edit?(@user)
			render 'shared/unauthorized'
			return
		end

    @user.destroy

		redirect_to users_url # DNE
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
end
