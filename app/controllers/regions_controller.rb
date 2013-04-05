class RegionsController < ApplicationController

  before_filter :region_filter

  # GET /regions
  def index
    @regions = Region.all.sort_by{ |r| r.name}
  end

  # GET /regions/new
  def new
    @region = Region.new
  end

  # GET /regions/1/edit
  def edit
    @region = Region.find(params[:id])
  end

  # POST /regions
  def create
    @region = Region.new(params[:region])

    if @region.save
      flash.notice = 'Region was successfully created'
      redirect_to :action => :index
    else
      render action: "new"
    end
  end

  # PUT /regions/1
  def update
    @region = Region.find(params[:id])

    if @region.update_attributes(params[:region])
      flash.notice = 'Region was successfully updated'
      redirect_to :action => :index
    else
      render action: "edit"
    end
  end

  # DELETE /regions/1
  def destroy
    @region = Region.find(params[:id])
    @region.destroy

    redirect_to :action => :index
  end

  private

  # Simplify actions, only admins have access
  def region_filter
    if !@cas_user.is_admin?
      render 'shared/forbidden'
      return false
    end
    return true
  end

end
