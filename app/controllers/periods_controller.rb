class PeriodsController < HomeController

	# GET /periods
	def index
		if !@cas_user.is_admin?
			render 'shared/unauthorized'
			return
		end
		@periods = Period.all
		@new_period = Period.new
		@regions = Region.all
		@years = 2012..Date.today.year
	end

	# POST /periods
	def create
		if !@cas_user.is_admin?
			render 'shared/unauthorized'
			return
		end

		#TODO: sanitize input
		if p = Period.find_by_region_id_and_year(params[:period][:region_id], params[:period][:year])
			flash.alert = "The period #{p.name} already exists"
		else
			@period = Period.new(params[:period])
			if @period.save
				flash.notice = "Period #{@period.name} created"
			else
				flash.alert = 'An error occurred while saving'
			end
		end

		redirect_to :action => :index
	end

  # GET /periods/1
  def show
    @period = Period.find(params[:id])
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
  end

	# GET /periods/1/fields
	def fields
		@period = Period.find(params[:id])
		if !@period.can_view?(@cas_user)
			render 'shared/unauthorized'
			return
		end
	end

	# POST /periods/1/update_fields
	def update_fields
		@period = Period.find(params[:id])
		if !@period.can_edit?(@cas_user)
			render 'shared/unauthorized'
			return
		end

		# TODO: sanitize input

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

		redirect_to :action => :fields, :id => params[:id]
	end
	
	# GET /periods/1/benchmarks
	def benchmarks
		@period = Period.find(params[:id])
		if !@period.can_view?(@cas_user)
			render 'shared/unauthorized'
			return
		end
	end

	# POST /periods/1/update_benchmarks
	def update_benchmarks
		@period = Period.find(params[:id])
		if !@period.can_edit?(@cas_user)
			render 'shared/unauthorized'
			return
		end
		
		# TODO: sanitize input

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

		redirect_to :action => :benchmarks, :id => params[:id]
	end

	# GET /periods/1/list
	def list
		@period = Period.find(params[:id])
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
	end

end
