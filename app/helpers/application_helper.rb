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

	def add_javascript(script)
		if @javascripts.nil?
			@javascripts = Array.new
			@javascripts << script
		else
			@javascripts << script
		end

		@javascripts.uniq! #So you can add them multiple times
	end
end
