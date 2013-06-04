module ApplicationHelper

  def set_flash_from_block(type, &block)
    flash.now[type] = capture(&block) if block
  end

  def title(title, &block)
    @page_title = title
    if block
      content = capture(&block)
      if content and content.strip != ''
        @page_description = content
      end
    end
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

  def view_pct(p)
    "#{p}%" if p
  end

end
