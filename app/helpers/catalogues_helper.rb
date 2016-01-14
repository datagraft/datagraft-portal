module CataloguesHelper
  def catalogue_path(catalogue, parameters = {})
    "/#{catalogue.user.username}/catalogues/#{catalogue.slug}#{ "?#{parameters.to_query}" if parameters.present? }"
  end

  def new_catalogue_path
    "/#{current_user.username}/catalogues/new"
  end

  def catalogues_path
    return "/explore" unless user_signed_in?

    return "/#{current_user.username}/catalogues"
  end
  def catalogue_edit_path(catalogue, parameters = {})
    catalogue_generic_path(catalogue, '/edit', parameters)
  end
  
  def catalogue_star_path(catalogue, parameters = {})
    catalogue_generic_path(catalogue, '/star', parameters)
  end

  def catalogue_unstar_path(catalogue, parameters = {})
    catalogue_generic_path(catalogue, '/unstar', parameters)
  end
  
  private
  def catalogue_generic_path(catalogue, method, parameters = {})
    #TODO error??
    return "" if catalogue.user.nil?

    "/#{catalogue.user.username}/catalogues/#{catalogue.slug}#{method}#{ "?#{parameters.to_query}" if parameters.present? }"
  end
end
