class PeriodsController < ApplicationController

  # GET /periods
  def index
    if !current_user.is_admin?
      render 'shared/forbidden'
      return
    end
    @periods = Period.all.sort_by{|p| [-p.year, p.region.name]}
    @new_period = Period.new(:year => Date.today.year)
    @regions = Region.all
    @years = 2000..Date.today.year + 1
  end

  # POST /periods
  def create
    if !current_user.is_admin?
      render 'shared/forbidden'
      return
    end

    if p = Period.find_by_region_id_and_year(params[:period][:region_id], params[:period][:year])
      flash.alert = "The period #{p.name} already exists"
    else
      @period = Period.new(params[:period])
      if @period.save
        flash.notice = "Period #{@period.name} created"

        # Download data
        if @period.keep_updated
          if Sitrack.update_period(@period)
            @period.last_updated = DateTime.now
            @period.save
          end
        end
      else
        flash.alert = 'An error occurred while saving'
      end
    end

    redirect_to :action => :index
  end

  # GET /periods/1
  def show
    if !@period = Period.find_by_id(params[:id])
      render 'shared/not_found'
      return
    end
    if !@period.can_view?(current_user)
      render 'shared/forbidden'
      return
    end

    @new_group = Group.new
    @new_group.period = @period
    
    @new_team = Team.new
    @new_team.period = @period
    
    @new_admin = PeriodAdmin.new
    @new_admin.period = @period

    member_breadcrumbs
  end

  # DELETE /periods/1
  def destroy
    if !current_user.is_admin?
      render 'shared/forbidden'
      return
    end
    if !@period = Period.find_by_id(params[:id])
      render 'shared/not_found'
      return
    end

    if @period.destroy
      flash.notice = 'Period deleted'
    else
      flash.alert = 'Period not deleted'
    end

    redirect_to :action => :index
  end

  # GET /periods/1/toggle_updated
  def toggle_updated
    if !current_user.is_admin?
      render 'shared/forbidden'
      return
    end
    if !@period = Period.find_by_id(params[:id])
      render 'shared/not_found'
      return
    end

    @period.keep_updated = !@period.keep_updated

    if @period.save
      flash.notice = 'Period updated'
    else
      flash.notice = 'Failed to update period'
    end

    redirect_to :action => :index
  end

  # POST /periods/1/do_update
  def do_update
    if !@period = Period.find_by_id(params[:id])
      render 'shared/not_found'
      return
    end
    if !@period.can_edit?(current_user)
      render 'shared/forbidden'
      return
    end

    Sitrack.update_period(@period)

    redirect_to :back
  end

  # GET /periods/1/fields
  def fields
    if !@period = Period.find_by_id(params[:id])
      render 'shared/not_found'
      return
    end
    if !@period.can_view?(current_user)
      render 'shared/forbidden'
      return
    end
    member_breadcrumbs
  end

  # POST /periods/1/update_fields
  def update_fields
    if !@period = Period.find_by_id(params[:id])
      render 'shared/not_found'
      return
    end
    if !@period.can_edit?(current_user)
      render 'shared/forbidden'
      return
    end

    valid = true

    # Update old fields
    for field in @period.report_fields
      id = "field_#{field.id}"
      if params[id]
        if params[id].delete('remove') == '1'
          valid = false if !field.destroy
        else
          valid = false if !field.update_attributes(params[id])
        end
      end
    end

    # Add new fields
    params.each do |key, hash|
      if key =~ /^newfield\_(\d+)/
        if hash.delete('remove') != '1'
          field = @period.report_fields.build(hash)
          valid = false if !field.save
        end
      end
    end

    if !valid
      member_breadcrumbs
      @period.valid? # Run validations
      render :action => :fields
    else
      flash.notice = 'Fields updated'
      redirect_to :action => :fields, :id => params[:id]
    end
  end

  # GET /periods/1/benchmarks
  def benchmarks
    if !@period = Period.find_by_id(params[:id])
      render 'shared/not_found'
      return
    end
    if !@period.can_view?(current_user)
      render 'shared/forbidden'
      return
    end
    member_breadcrumbs
  end

  # POST /periods/1/update_benchmarks
  def update_benchmarks
    if !@period = Period.find_by_id(params[:id])
      render 'shared/not_found'
      return
    end
    if !@period.can_edit?(current_user)
      render 'shared/forbidden'
      return
    end

    valid = true

    # Update old benchmarks
    for bm in @period.bmarks
      id = "benchmark_#{bm.id}"
      if params[id]
        if params[id].delete('remove') == '1'
          valid = false if !bm.destroy
        else
          valid = false if !bm.update_attributes(params[id])
        end
      end
    end

    # Add new benchmarks
    params.each do |key, hash|
      if key =~ /^newbenchmark\_(\d+)/
        if hash.delete('remove') != '1'
          bm = @period.bmarks.build(hash)
          valid = false if !bm.save
        end
      end
    end

    if !valid
      @period.valid? #Run validations
      member_breadcrumbs
      render :action => :benchmarks
    else
      flash.notice = 'Benchmarks updated'
      redirect_to :action => :benchmarks, :id => params[:id]
    end
  end

  # GET /periods/1/list
  def list
    if !@period = Period.find_by_id(params[:id])
      render 'shared/not_found'
      return
    end
    if !@period.can_view?(current_user)
      render 'shared/forbidden'
      return
    end

    @list_title = "#{@period.name} Complete List"
    @list_type = 'period'
    @fields = params[:fields] || Hash.new

    if @fields[:show_all] == '1'
      @assignments = @period.assignments
    else
      @assignments = @period.assignments.active
    end
    @assignments = @assignments.sort_by{|a| a.user.sort_name}

    if params[:commit] == 'Download Excel'
      render 'assignments/list.xml', :content_type => 'application/xls'
      return
    end

    if params[:commit] == 'Clear'
      # Clear selections
      @fields = Hash.new
    end

    member_breadcrumbs
    render 'assignments/list', :layout => 'list'
  end

  private
  # Adds breadcrumbs for all member views
  def member_breadcrumbs
    add_breadcrumb(@period.name, url_for(@period), true, 'Coaching Period')
  end

end
