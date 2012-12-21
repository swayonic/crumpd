class ReportsController < HomeController
  
	# GET /assignments/1/reports
  def index
		@assignment = Assignment.find(params[:assignment_id])
		if !@assignment.can_view?(@user)
			render 'shared/unauthorized'
			return
		end
  end

  # GET /reports/1
  def show
    @report = Report.find(params[:id])
		if !@report.assignment.can_view?(@user)
			render 'shared/unauthorized'
			return
		end
  end

  # GET /assignments/1/reports/new
  def new
		@assignment = Assignment.find(params[:assignment_id])
		if !@assignment.can_edit?(@user)
			render 'shared/unauthorized'
			return
		end

    @report = @assignment.reports.new

		for g in @assignment.goals
			l = @report.goal_lines.new(:frequency => g.frequency, :pledged => @assignment.goal_pledged(g.frequency), :inhand => @assignment.goal_inhand(g.frequency))
		end

		for f in @assignment.period.report_fields
			l = @report.field_lines.new
			l.report_field = f
		end
  end

  # GET /reports/1/edit
  def edit
    @report = Report.find(params[:id])
		if !@report.assignment.can_edit?(@user)
			render 'shared/unauthorized'
			return
		end
		
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
		if !@assignment.can_edit?(@user)
			render 'shared/unauthorized'
			return
		end
    @report = @assignment.reports.new(params[:report])

		params.each do |key, value|
			if key =~ /^goal_(\d+)$/
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

    if @report.save
			redirect_to @report, notice: 'Report was successfully created.'
		else
			render action: "new"
		end
  end

  # PUT /reports/1
  def update
		@report = Report.find(params[:id])
		if !@report.assignment.can_edit?(@user)
			render 'shared/unauthorized'
			return
		end
		valid = true
		

		params.each do |key, value|
			if key =~ /^goal_(\d+)$/
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
		if !@report.assignment.can_edit?(@user)
			render 'shared/unauthorized'
			return
		end
    @report.destroy

    respond_to do |format|
      format.html { redirect_to reports_url }
      format.json { head :no_content }
    end
  end
end
