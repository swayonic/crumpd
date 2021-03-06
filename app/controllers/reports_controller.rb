class ReportsController < ApplicationController

  # GET /reports/1
  def show
    if !@report = Report.find_by_id(params[:id])
      render 'shared/not_found'
      return
    end
    @assignment = @report.assignment
    if !@assignment.can_view_reports?(current_user)
      render 'shared/forbidden'
      return
    end
    member_breadcrumbs
  end

  # GET /assignments/1/reports/new
  def new
    if !@assignment = Assignment.find_by_id(params[:assignment_id])
      render 'shared/not_found'
      return
    end
    if !@assignment.can_edit_reports?(current_user)
      render 'shared/forbidden'
      return
    end

    @report = @assignment.reports.new
    @report.date = Date.today

    @report.partners_lines.build(:total => @assignment.partners_count)

    for g in @assignment.goals
      @report.goal_lines.build(:frequency => g.frequency, :pledged => @assignment.goal_pledged(g.frequency), :inhand => @assignment.goal_inhand(g.frequency))
    end

    for f in @assignment.period.report_fields
      l = @report.field_lines.build
      l.report_field = f
    end

    collection_breadcrumbs
  end

  # GET /reports/1/edit
  def edit
    if !@report = Report.find_by_id(params[:id])
      render 'shared/not_found'
      return
    end
    assignment = @report.assignment
    if !assignment.can_edit_reports?(current_user)
      render 'shared/forbidden'
      return
    end

    for g in assignment.goals
      if @report.goal_lines.find_by_frequency(g.frequency).nil?
        l = @report.goal_lines.new(:frequency => g.frequency)
      end
    end
    for f in assignment.period.report_fields
      if @report.field_lines.find_by_report_field_id(f.id).nil?
        l = @report.field_lines.new
        l.report_field = f
      end
    end
    member_breadcrumbs
  end

  # POST /assignments/1/reports
  def create
    if !@assignment = Assignment.find_by_id(params[:assignment_id])
      render 'shared/not_found'
      return
    end
    if !@assignment.can_edit_reports?(current_user)
      render 'shared/forbidden'
      return
    end
    @report = @assignment.reports.new(params[:report])

    params.each do |key, value|
      if key == 'partners_line'
        l = @report.partners_lines.build
        l.total = value[:total]
      elsif key =~ /^goal_(\d+)$/
        l = @report.goal_lines.build
        l.frequency = $1
        l.inhand = value[:inhand]
        l.pledged = value[:pledged]
      elsif key =~ /^field_(\d+)$/
        l = @report.field_lines.build
        l.report_field_id = $1
        l.value = value[:value]
      end
    end

    @report.updated_by = current_user.id

    if @report.save
      redirect_to @report, notice: 'Report was successfully created.'
    else
      collection_breadcrumbs
      render action: "new"
    end
  end

  # PUT /reports/1
  def update
    if !@report = Report.find_by_id(params[:id])
      render 'shared/not_found'
      return
    end
    if !@report.assignment.can_edit_reports?(current_user)
      render 'shared/forbidden'
      return
    end
    valid = true

    params.each do |key, value|
      if key == 'partners_line'
        if @report.partners_lines.count == 0
          @report.partners_lines.build
        elsif @report.partners_lines.count > 1
          throw "Something's wrong with report.partners_lines for report ##{@report.id}"
        end
        for l in @report.partners_lines # Should only be exactly one
          l.total = value[:total]
          valid = false if !l.save
        end
      elsif key =~ /^goal_(\d+)$/
        freq = Integer($1)
        if !@report.goal_lines.find_by_frequency(freq)
          @report.goal_lines.build(:frequency => freq)
        end
        @report.goal_lines.select{|l| l.frequency == freq}.each do |l|
          l.inhand = value[:inhand]
          l.pledged = value[:pledged]
          valid = false if !l.save
        end
      elsif key =~ /^field_(\d+)$/
        id = Integer($1)
        if !@report.field_lines.find_by_report_field_id(id)
          @report.field_lines.build(:report_field_id => id)
        end
        @report.field_lines.select{|l| l.report_field_id == id}.each do |l|
          l.value = value[:value]
          valid = false if !l.save
        end
      end
    end

    @report.updated_by = current_user.id
    valid = false if !@report.update_attributes(params[:report])
    
    if valid
      redirect_to @report, notice: 'Report was successfully updated.'
    else
      member_breadcrumbs
      render action: "edit"
    end
  end

  # DELETE /reports/1
  def destroy
    if !@report = Report.find_by_id(params[:id])
      render 'shared/not_found'
      return
    end
    if !@report.can_delete?(current_user)
      render 'shared/forbidden'
      return
    end
    a = @report.assignment
    @report.destroy

    redirect_to a
  end

  # GET /assignments/1/reports/list
  def list
    if !@assignment = Assignment.find_by_id(params[:assignment_id])
      render 'shared/not_found'
      return
    end
    if !@assignment.can_view_reports?(current_user)
      render 'shared/forbidden'
      return
    end

    @period = @assignment.period
    @list_title = "Reports - #{@assignment.user.display_name}"
    @list_type = 'reports'

    @fields = params[:fields]
    if !@fields
      @fields = Hash.new
      # Start with these
      for g in @assignment.goals
        @fields["#{g.frequency}_inhand_pct"] = '1'
      end
    end

    if params[:commit] == 'Download Excel'
      render 'list.xml', :content_type => 'application/xls'
      return
    end

    collection_breadcrumbs
    render :layout => 'list'
  end

  private
  # Adds breadcrumbs for all collection views
  def collection_breadcrumbs
    assignment = @assignment || @report.assignment
    add_breadcrumb(assignment.period.name, url_for(assignment.period), assignment.period.can_view?(current_user), 'Coaching Period')
    if assignment.group 
      add_breadcrumb(assignment.group.display_name, url_for(assignment.group), assignment.group.can_view?(current_user), 'Coaching Group')
    elsif assignment.team
      add_breadcrumb(assignment.team.display_name, url_for(assignment.team), assignment.team.can_view?(current_user), 'Team')
    end
    add_breadcrumb(assignment.user.display_name, url_for(assignment), true, 'Assignment')
  end

  # Adds breadcrumbs for all member views
  def member_breadcrumbs
    collection_breadcrumbs
    add_breadcrumb(@report.date.strftime('%b %e Report'), url_for(@report), true, 'Report')
  end

end
