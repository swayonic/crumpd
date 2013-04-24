module ListHelper

  def excel_sheet(title, &block)
    content = block ? capture(&block) : nil
    render :partial => 'list/spreadsheet.xml', :locals => {
      :title => title,
      :table_content => content
    }
  end

end
