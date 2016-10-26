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

  def thing_versions_path(thing, parameters = {})
    thing_generic_path(thing, '/versions', parameters)
  end

  def thing_fork_path(thing, parameters = {})
    thing_generic_path(thing, '/fork', parameters)
  end

  def things_path(thing, parameters = {})
    classname = thing.class.name
    username = thing.user.nil? ? 'myassets' : thing.user.username
    "/#{username}/#{classname.underscore.pluralize}#{ "?#{parameters.to_query}" if parameters.present? }"
  end

  def new_generic_thing_path
    return if not user_signed_in?
    username = current_user.username
    "/#{username}/#{params[:controller]}/new"
  end
  
  private


      classname = thing.class.name

      slug = (thing.nil? || thing.new_record?) ? '' : thing.slug

      "/#{user.username}/#{classname.underscore.pluralize}/#{slug}#{method}#{ "?#{parameters.to_query}" if parameters.present? }"
    end
end
