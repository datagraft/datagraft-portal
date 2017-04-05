module SparqlEndpointsHelper

  def new_sparql_endpoint_path(parameters = {})
    return "/"+current_user.username+"/sparql_endpoints/new#{ "?#{parameters.to_query}" if parameters.present? }"
  end


  # Get repository size for SPARQL endpoint
#  def repository_size
#    result = nil
#    
#    if @thing.public
#      # Create a tmp user (public SPARQL endpoint)
#      tmpuser = User.new;
#      tmpuser.get_ontotext_repository_size(@thing)
#    else
#      # Use current user (private SPARQL endpoint)
#      current_user.get_ontotext_repository_size(@thing)
#    end
#    
#    return result
#  end

  
  # Get repository size for SPARQL endpoint
  def repository_size_param(user, se)
    raise CanCan::AccessDenied.new("Not allowed to access Sparql Endpoint", :read, se) unless can? :read, se
    
    begin
      return user.get_ontotext_repository_size(se)

    rescue Exception => e
      puts 'Error getting repository size'
      puts e.message
      puts e.backtrace.inspect

      # Use cached size
      return se.cached_size
    end
  end

  
  # Get cached repository size for SPARQL endpoint
  # Do not think is needed!
  def repository_cached_size_param (user, se)
    return "0" ## ToDo replace with real code when model is updated
  end

  
  # Return all queries
  def all_queries
    return Thing.where(type: 'Query')
  end


  # Search for queries
  def search_for_existing_queries
    user = @thing.user
    tmp_user = user.queries.includes(:user).where(public: false)
    tmp_pub = Thing.public_list.includes(:user).where(:type => ['Query'])

    return tmp_user + tmp_pub
  end


  # Check if query links to sparql endpoint
  def query_links_to_sparql_endpoint(query, sparql_endpoint)
    return SparqlEndpointQuery.exists?({query_id: query.id, sparql_endpoint_id: sparql_endpoint.id})
  end

end
