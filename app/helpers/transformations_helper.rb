module TransformationsHelper
  def transformation_path(transformation, parameters = {})
    "/transformations/#{transformation.user_id}/#{transformation.slug}#{ "?#{parameters.to_query}" if parameters.present? }"
  end

  def edit_transformation_path(transformation, parameters = {})
    "/transformations/#{transformation.user_id}/#{transformation.slug}/edit#{ "?#{parameters.to_query}" if parameters.present? }"
  end
end
