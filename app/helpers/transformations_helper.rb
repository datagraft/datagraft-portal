module TransformationsHelper
  def transformation_path(transformation, parameters = {})
    "/#{transformation.user.username}/transformations/#{transformation.slug}#{ "?#{parameters.to_query}" if parameters.present? }"
  end

  #def edit_transformation_path(transformation, parameters = {})
  #  "/transformations/#{transformation.user.username}/#{transformation.slug}/edit#{ "?#{parameters.to_query}" if parameters.present? }"
  #end

  def new_transformation_path
    "/#{current_user.username}/transformations/new"
  end
  
  def transformations_path
    return "/explore" unless user_signed_in?
    
    return "/#{current_user.username}/transformations"
  end
  
end
