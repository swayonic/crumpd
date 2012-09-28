class PeriodsController < ApplicationController
	before_filter :admin_only, :except => :show
  # GET /periods
  def index
		redirect_to root_path
  end

  # GET /periods/1
  def show
		#TODO authentication
    @period = Period.find(params[:id])
  end

  # GET /periods/new
  def new
    @period = Period.new
  end

  # GET /periods/1/edit
  def edit
    @period = Period.find(params[:id])
  end

  # POST /periods
  def create
    @period = Period.new(params[:period])
		
		if @period.save
      redirect_to @period, notice: 'Period was successfully created.'
    else
      render action: "new"
    end
  end

  # PUT /periods/1
  def update
    @period = Period.find(params[:id])

    if @period.update_attributes(params[:period])
      redirect_to @period, notice: 'Period was successfully updated.'
    else
      render action: "edit"
		end
  end

  # DELETE /periods/1
  def destroy
    @period = Period.find(params[:id])
    @period.destroy
    
		redirect_to periods_url
  end

end