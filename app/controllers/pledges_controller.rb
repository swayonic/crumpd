class PledgesController < HomeController

	# POST /assignment/1/pledges
	def create
		@assignment = Assignment.find(params[:assignment_id])
		if !@assignment.can_edit?(@sso)
			render 'shared/unauthorized'
			return
		end

		@pledge = @assignment.pledges.build(params[:pledge])
		@pledge.name.strip!

		if @pledge.assignment.pledges.select{ |p| p.name == @pledge.name and p.frequency == @pledge.frequency}.count > 0
			flash.alert = "Cannot add another pledge with the name \"#{@pledge.name}\" as a #{Goal.freq_title @pledge.frequency} gift. Please choose a different name or remove the other pledge."
		elsif @pledge.save
			flash.notice = 'Pledge added'
		else
			flash.alert = 'Pledge not added: an error occured while saving'
		end
		
		redirect_to @pledge.assignment
	end

	# PUT /pledges/1/toggle
	def toggle
		@pledge = Pledge.find(params[:id])
		if !@pledge.assignment.can_edit?(@sso)
			render 'shared/unauthorized'
			return
		end

		@pledge.is_in_hand = !@pledge.is_in_hand

		if @pledge.save
			# Do nothing
		else
			flash.alert = 'Pledge not updated: an error occured while saving'
		end

		redirect_to @pledge.assignment
  end

	# DELETE /pledges/1
	def destroy
		@pledge = Pledge.find(params[:id])
		if !@pledge.assignment.can_edit?(@sso)
			render 'shared/unauthorized'
			return
		end

		@pledge.destroy

		redirect_to @pledge.assignment
	end
end
