module QueriesHelper
  def queries_path
    return "/explore" unless user_signed_in?
    return "/#{current_user.username}/queries"
  end

  def query_execute_path(query, queriable_data_store, parameters = {})
    return "" if query.nil? || query.user.nil? || queriable_data_store.nil? || queriable_data_store.user.nil?
    "/#{query.user.username}/queries/#{query.slug}/execute/#{queriable_data_store.user.username}/#{queriable_data_store.slug}#{ "?#{parameters.to_query}" if parameters.present? }"
  end
end