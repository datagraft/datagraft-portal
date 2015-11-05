module ApplicationHelper
  def thing_path(thing, parameters = {})
    classname = thing.class.name
    if thing.user.nil?
      return "/#{classname.underscore.pluralize}#{ "?#{parameters.to_query}" if parameters.present? }"
    end

    #"/#{classname.underscore.pluralize}/#{thing.user.username}/#{thing.slug}#{ "?#{parameters.to_query}" if parameters.present? }"
    "/#{thing.user.username}/#{classname.underscore.pluralize}/#{thing.slug}#{ "?#{parameters.to_query}" if parameters.present? }"
  end

  def thing_edit_path(thing, parameters = {})
    classname = thing.class.name

    if thing.user.nil?
      return ""
    end
    
    #"/#{classname.underscore.pluralize}/#{thing.user.username}/#{thing.slug}#{ "?#{parameters.to_query}" if parameters.present? }"
    "/#{thing.user.username}/#{classname.underscore.pluralize}/#{thing.slug}/edit#{ "?#{parameters.to_query}" if parameters.present? }"
  end

  
  def transformations_path
    if user_signed_in?
      return "/#{current_user.username}/transformations"
    end

    "/explore"
  end

  def title(page_title)
    content_for :title, page_title.to_s
  end
end
