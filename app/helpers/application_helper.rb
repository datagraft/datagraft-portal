module ApplicationHelper
  def title(page_title)
    content_for :title, page_title.to_s
  end

  def setOption(option)
    @options = Hash.new if @options.nil?
    @options[option] = true;
  end

  def hasOption(option)
    !@options.nil? && @options[option]
  end

  private

end