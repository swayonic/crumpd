class ReportsController < HomeController
  
	# GET /assignments/1/reports
  def index
		@assignment = Assignment.find(params[:assignment_id])
  end

  # GET /reports/1
  def show
    @report = Report.find(params[:id])
  end

  # GET /assignments/1/reports/new
  def new
		@assignment = Assignment.find(params[:assignment_id])
    @report = @assignment.reports.new

		for g in @assignment.goals
			l = @report.goal_lines.new(:frequency => g.frequency)
		end

		for f in @assignment.period.report_fields
			l = @report.field_lines.new
			l.report_field = f
		end
  end

  # GET /reports/1/edit
  def edit
    @report = Report.find(params[:id])
		
		for g in @report.assignment.goals
			if @report.goal_lines.find_by_frequency(g.frequency).nil?
				l = @report.goal_lines.new(:frequency => g.frequency)
			end
		end
		for f in @report.assignment.period.report_fields
			if @report.field_lines.find_by_report_field_id(f.id).nil?
				l = @report.field_lines.new
				l.report_field = f
			end
		end
  end

  # POST /assignments/1/reports
  def create
		@assignment = Assignment.find(params[:assignment_id])
    @report = @assignment.reports.new(params[:report])

		params.each do |key, value|
			if key =~ /^goal_(\d+)$/
				l = @report.goal_lines.new
				l.frequency = $1
				l.inhand = value[:inhand]
				l.pledged = value[:pledged]
				l.report = @report
			elsif key =~ /^field_(\d+)$/
				l = @report.field_lines.new
				l.report_field_id = $1
				l.value = value[:value]
				l.report = @report
			end
		end

    if @report.save
			redirect_to @report, notice: 'Report was successfully created.'
		else
			render action: "new"
		end
  end

  # PUT /reports/1
  def update
		@report = Report.find(params[:id])
		valid = true
		

		params.each do |key, value|
			if key =~ /^goal_(\d+)$/
				l = @report.goal_lines.find_by_frequency($1) || @report.goal_lines.new
				l.frequency = $1
				l.inhand = value[:inhand]
				l.pledged = value[:pledged]
				l.report = @report
				valid = false if !l.save
			elsif key =~ /^field_(\d+)$/
				l = @report.field_lines.find_by_report_field_id($1) || @report.field_lines.new
				l.report_field_id = $1
				l.value = value[:value]
				l.report = @report
				valid = false if !l.save
			end
		end

		valid = false if !@report.update_attributes(params[:report])
		
		if valid
			redirect_to @report, notice: 'Report was successfully updated.'
		else
			render action: "edit"
		end
  end

  # DELETE /reports/1
  # DELETE /reports/1.json
  def destroy
    @report = Report.find(params[:id])
    @report.destroy

    respond_to do |format|
      format.html { redirect_to reports_url }
      format.json { head :no_content }
    end
  end
end
