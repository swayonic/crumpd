module ApplicationHelper

	def flash_header
		render :partial => 'shared/flash_header'
	end

	def print_flashes
		render :partial => 'shared/flash'
	end

	def title(title)
		@page_title = title
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

	def help_tip(text)
		render :partial => 'shared/help_tip', :locals => {:text => text} if text and !text.blank?
	end

	def autofocus(id)
		render :partial => 'shared/autofocus', :locals => {:id => id}
	end

end
