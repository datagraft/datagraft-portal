module ApplicationHelper
  def thing_path(thing, parameters = {})
    "/transformations/#{thing.user.username}/#{thing.slug}#{ "?#{parameters.to_query}" if parameters.present? }"
  end
end
