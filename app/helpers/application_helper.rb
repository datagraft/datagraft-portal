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

  def render_markdown(markdown)
    if @markdown.nil?
      @markdown = Redcarpet::Markdown.new(
        Redcarpet::Render::HTML.new({
          safe_links_only: true
        }),
        autolink: true,
        tables: true,
        footnotes: true)
    end

    return '' if markdown.nil?

    @markdown.render(markdown).html_safe
  end

  COMMON_LICENSES = %w(CC0 CC-BY CC-BY-SA CC-BY-ND CC-BY-NC CC-BY-NC-SA CC-BY-NC-ND WTFPL MIT)
  def get_common_licenses
    return COMMON_LICENSES
  end

  private

end