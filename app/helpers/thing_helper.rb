module ThingHelper
  def thing_url(thing, parameters = {})
    return root_url[0...-1] + thing_path(thing, parameters)
  end
  
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

  def thing_metadata_path(thing, parameters = {})
    thing_generic_path(thing, '/metadata', parameters)
  end

  def things_path(thing, parameters = {})
    classname = thing.class.name
    return "" if thing.user.nil?
    "/#{thing.user.username}/#{classname.underscore.pluralize}#{ "?#{parameters.to_query}" if parameters.present? }"
  end
  
  private

    def thing_generic_path(thing, method, parameters = {})
      classname = thing.class.name
      #TODO error??
      return "" if thing.user.nil?
      "/#{thing.user.username}/#{classname.underscore.pluralize}/#{thing.slug}#{method}#{ "?#{parameters.to_query}" if parameters.present? }"
    end
end
