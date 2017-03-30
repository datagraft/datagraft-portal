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

  def get_license_info(license)
    ret = {}
    ret[:path] = ""
    ret[:tip] = ""

    if license == "CC0"
      ret[:path] = "https://creativecommons.org/publicdomain/zero/1.0/"
      ret[:tip] = "Creative Commons: Universal - Public Domain Dedication"
    elsif license == "CC-BY"
      ret[:path] = "https://creativecommons.org/licenses/by/4.0/"
      ret[:tip] = "Creative Commons: Attribution"
    elsif license == "CC-BY-SA"
      ret[:path] = "https://creativecommons.org/licenses/by-sa/4.0"
      ret[:tip] = "Creative Commons: Attribution-ShareAlike"
    elsif license == "CC-BY-ND"
      ret[:path] = "https://creativecommons.org/licenses/by-nd/4.0"
      ret[:tip] = "Creative Commons: Attribution-NoDerivs"
    elsif license == "CC-BY-NC"
      ret[:path] = "https://creativecommons.org/licenses/by-nc/4.0"
      ret[:tip] = "Creative Commons: Attribution-NonCommercial"
    elsif license == "CC-BY-NC-SA"
      ret[:path] = "https://creativecommons.org/licenses/by-nc-sa/4.0"
      ret[:tip] = "Creative Commons: Attribution-NonCommercial-ShareAlike"
    elsif license == "CC-BY-NC-ND"
      ret[:path] = "https://creativecommons.org/licenses/by-nc-nd/4.0"
      ret[:tip] = "Creative Commons: Attribution-NonCommercial-NonDerivs"
    elsif license == "WTFPL"
      ret[:path] = "http://www.wtfpl.net/about"
      ret[:tip] = "WTFPL – Do What the Fuck You Want to Public License"
    elsif license == "MIT"
      ret[:path] = "https://opensource.org/licenses/MIT"
      ret[:tip] = "The MIT License"
    end
    return ret
  end

  private

end
