module TransformationsHelper
  #def transformation_path(transformation, parameters = {})
  #  "/transformations/#{transformation.user.username}/#{transformation.slug}#{ "?#{parameters.to_query}" if parameters.present? }"
  #end

  #def edit_transformation_path(transformation, parameters = {})
  #  "/transformations/#{transformation.user.username}/#{transformation.slug}/edit#{ "?#{parameters.to_query}" if parameters.present? }"
  #end

  def new_transformation_path
    "/transformations/new"
  end
end
