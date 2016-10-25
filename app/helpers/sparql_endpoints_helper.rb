module SparqlEndpointsHelper

  def new_sparql_endpoint_path(parameters = {})
    return "/"+current_user.username+"/sparql_endpoints/new#{ "?#{parameters.to_query}" if parameters.present? }"
  end

  def repository_size
    if @thing.public
      repository_size_of_public_endpoint
    else  
      current_user.get_ontotext_repository_size(@thing.uri)
    end
  end

  def repository_size_of_public_endpoint
    return 'unknown number of' if not @thing.uri
    
    connect = Faraday.new
    resp_size = connect.get do |req|
      req.url @thing.uri+'/size'
      req.headers['Content-Type'] = 'application/ld+json'
      req.options.timeout = 720
    end  
    
    throw ("Unable to get size of the Ontotext Repository - " + resp_size.body + " - " + resp_size.status) unless 
    resp_size.status.between?(200, 299)
    
    return resp_size.body    
  end

  def all_queries
    return Thing.where(type: 'Query')
  end

end
