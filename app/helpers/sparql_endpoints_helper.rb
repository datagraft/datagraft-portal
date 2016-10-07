module SparqlEndpointsHelper

  def new_sparql_endpoint_path(parameters = {})
    return "/"+current_user.username+"/sparql_endpoints/new#{ "?#{parameters.to_query}" if parameters.present? }"
  end

  def repository_size
    current_user.get_ontotext_repository_size(@thing.uri)
  end

  def all_queries
    return Thing.where(type: 'Query')
  end
  
end
