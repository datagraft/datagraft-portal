module QueriesHelper
  def queries_path
    return "/explore" unless user_signed_in?
    return "/#{current_user.username}/queries"
  end

  def new_query_path
    "/#{current_user.username}/queries/new" if user_signed_in?
  end

# Original helper method for queriable data stores
=begin
  def query_execute_path(query, queriable_data_store, parameters = {})
    return "" if query.nil? || query.user.nil? || queriable_data_store.nil? || queriable_data_store.user.nil?
    "/#{query.user.username}/queries/#{query.slug}/execute/#{queriable_data_store.user.username}/#{queriable_data_store.slug}#{ "?#{parameters.to_query}" if parameters.present? }"
  end
=end
  
  def query_execute_path(query, sparql_endpoint, parameters = {})
    return "" if query.nil? || query.user.nil? || sparql_endpoint.nil? || sparql_endpoint.user.nil?
    "/#{query.user.username}/queries/#{query.slug}/execute_query/#{sparql_endpoint.user.username}/#{sparql_endpoint.slug}#{ "?#{parameters.to_query}" if parameters.present? }"
  end

  def query_execute_sparql_endpoint_path(query, sparql_endpoint, parameters = {})
    #"/#{query.user.username}/queries/#{query.slug}/execute/#{sparql_endpoint.user.username}/#{sparql_endpoint.slug}#{ "?#{parameters.to_query}" if parameters.present? }"
  end
  
  SPARQL_QUERY_TYPES = %w(SELECT CONSTRUCT)
  def get_sparql_query_types
    return SPARQL_QUERY_TYPES
  end
  
  def display_sparql_query_type(query_type)
    case query_type
      when "SELECT"
        return "SPARQL/S"
      when "CONSTRUCT"
        return "SPARQL/C"
      else
        return "SPARQL/S"
    end
  end 
  
end
