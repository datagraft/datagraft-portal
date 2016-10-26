module SparqlEndpointsHelper

  def new_sparql_endpoint_path(parameters = {})
    return "/"+current_user.username+"/sparql_endpoints/new#{ "?#{parameters.to_query}" if parameters.present? }"
  end


  # Get repository size for SPARQL endpoint
  def repository_size
    if @thing.public
      # Create a tmp user (public SPARQL endpoint)
      tmpuser = User.new;
      tmpuser.get_ontotext_repository_size(@thing)
    else
      # Use current user (private SPARQL endpoint)
      current_user.get_ontotext_repository_size(@thing)
    end
  end

  
  # Return all queries
  def all_queries
    return Thing.where(type: 'Query')
  end
  
  
  # Search for queries 
  def search_for_existing_queries
    user = @thing.user
    tmp_user = user.queries.where(public: false)
    tmp_pub = Thing.public_list.where(:type => ['Query'])

    return tmp_user + tmp_pub
  end

end
