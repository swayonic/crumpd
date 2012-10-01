module ApplicationHelper

	def flash_header
		render :partial => 'shared/flash_header'
	end

	def print_flashes
		render :partial => 'shared/flash'
	end

	def page_header(title)
		@page_title = title
		render :partial => 'shared/page_header', :locals => {:title => title}
	end
end
