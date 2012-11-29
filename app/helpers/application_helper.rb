module ApplicationHelper

	def flash_header
		render :partial => 'shared/flash_header'
	end

	def print_flashes
		render :partial => 'shared/flash'
	end

	# If no block given, assume title is also the header
	def page_header(title)
		page_header(title) do
			title
		end
	end

	def page_header(title, &block)
		if block_given?
			content = capture(&block)
		else
			content = title
		end
		@page_title = title
		render :partial => 'shared/page_header', :locals => {:title => content}
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

	def tooltip(text)
		render :partial => 'shared/tooltip', :locals => {:text => text}
	end

end
