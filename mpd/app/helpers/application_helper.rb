module ApplicationHelper

	def print_flashes
		render :partial => 'shared/flash', :locals => {:flash => flash}
	end
end
