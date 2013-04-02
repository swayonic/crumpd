class PeriodsController < HomeController

  # GET /periods
  def index
    if !@cas_user.is_admin?
      render 'shared/unauthorized'
      return
    end
    @periods = Period.all.sort_by{|p| [-p.year, p.region.name]}
    @new_period = Period.new(:year => Date.today.year)
    @regions = Region.all
    @years = 2000..Date.today.year + 1
  end

  # POST /periods
  def create
    if !@cas_user.is_admin?
      render 'shared/unauthorized'
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
    if !@period.can_view?(@cas_user)
      render 'shared/unauthorized'
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
    if !@cas_user.is_admin?
      render 'shared/unauthorized'
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
    if !@cas_user.is_admin?
      render 'shared/unauthorized'
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
    if !@period.can_edit?(@cas_user)
      render 'shared/unauthorized'
      return
    end

    if Sitrack.update_period(@period)
      @period.last_updated = DateTime.now
      @period.save
    end

    redirect_to :back
  end

  # GET /periods/1/fields
  def fields
    if !@period = Period.find_by_id(params[:id])
      render 'shared/not_found'
      return
    end
    if !@period.can_view?(@cas_user)
      render 'shared/unauthorized'
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
    if !@period.can_edit?(@cas_user)
      render 'shared/unauthorized'
      return
    end

    #TODO: Track errors during saving/deleting

    # Update old fields
    for field in @period.report_fields
      id = "field_#{field.id}"
      if params[id]
        if params[id].delete('remove') == '1'
          field.destroy
        else
          field.update_attributes(params[id])
        end
      end
    end

    # Add new fields
    params.each do |key, hash|
      if key =~ /^newfield\_(\d+)/
        if hash.delete('remove') != '1'
          field = @period.report_fields.build(hash)
          field.save
        end
      end
    end

    flash.notice = 'Fields updated'
    redirect_to :action => :fields, :id => params[:id]
  end
  
  # GET /periods/1/benchmarks
  def benchmarks
    if !@period = Period.find_by_id(params[:id])
      render 'shared/not_found'
      return
    end
    if !@period.can_view?(@cas_user)
      render 'shared/unauthorized'
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
    if !@period.can_edit?(@cas_user)
      render 'shared/unauthorized'
      return
    end
    
    #TODO: Track errors during saving/deleting

    # Update old benchmarks
    for bm in @period.bmarks
      id = "benchmark_#{bm.id}"
      if params[id]
        if params[id].delete('remove') == '1'
          bm.destroy
        else
          bm.update_attributes(params[id])
        end
      end
    end

    # Add new benchmarks
    params.each do |key, hash|
      if key =~ /^newbenchmark\_(\d+)/
        if hash.delete('remove') != '1'
          bm = @period.bmarks.build(hash)
          bm.save
        end
      end
    end

    flash.notice = 'Benchmarks updated'
    redirect_to :action => :benchmarks, :id => params[:id]
  end

  # GET /periods/1/list
  def list
    if !@period = Period.find_by_id(params[:id])
      render 'shared/not_found'
      return
    end
    if !@period.can_view?(@cas_user)
      render 'shared/unauthorized'
      return
    end

    @assignments = @period.assignments
    @fields = params[:fields] || Hash.new

    if params[:commit] == 'Download Excel'
      @title = "#{@period.name} Complete List"
      render 'assignments/list.xls', :content_type => 'application/xls'
      return
    end
    if params[:commit] == 'Clear'
      # Clear selections
      @fields = Hash.new
    end

    member_breadcrumbs
    render :layout => 'list'
  end

  private
  # Adds breadcrumbs for all member views
  def member_breadcrumbs
    add_breadcrumb(@period.name, url_for(@period), true, 'Coaching Period')
  end

end
