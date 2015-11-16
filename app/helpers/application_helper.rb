module ApplicationHelper
  def thing_path(thing, parameters = {})
    thing_generic_path(thing, '', parameters)
  end

  def thing_edit_path(thing, parameters = {})
    thing_generic_path(thing, '/edit', parameters)
  end

  def thing_star_path(thing, parameters = {})
    thing_generic_path(thing, '/star', parameters)
  end

  def thing_unstar_path(thing, parameters = {})
    thing_generic_path(thing, '/unstar', parameters)
  end
  
  def transformations_path
    return "/explore" unless user_signed_in?
    
    return "/#{current_user.username}/transformations"
  end

  def data_distributions_path(post=false)
    return "/data_distributions" if post
    return "/explore" unless user_signed_in?
    
    return "/#{current_user.username}/data_distributions"
  end

  def dashboard_path
    return "/dashboard"
  end

  def user_path(user)
    "/"+user.username
  end

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

  def thing_generic_path(thing, method, parameters = {})
    classname = thing.class.name

    return "" if thing.user.nil?
    
    "/#{thing.user.username}/#{classname.underscore.pluralize}/#{thing.slug}#{method}#{ "?#{parameters.to_query}" if parameters.present? }"
  end
end
