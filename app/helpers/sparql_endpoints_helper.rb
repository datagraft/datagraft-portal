module SparqlEndpointsHelper
  include ThingHelper

  def new_sparql_endpoint_path(parameters = {})
    return "/"+current_user.username+"/sparql_endpoints/new#{ "?#{parameters.to_query}" if parameters.present? }"
  end

  def sparql_endpoint_proxy_path(thing, parameters = {})
    thing_generic_path(thing, '/sparql', parameters)
  end


  # Get repository size for SPARQL endpoint
  def repository_size_param(user, se)
    raise CanCan::AccessDenied.new("Not allowed to access Sparql Endpoint", :read, se) unless can? :read, se

    begin
      if se.has_rdf_repo?
        rr = se.rdf_repo
        return rr.get_repository_size
      else
        return '0'
      end
    rescue => e
      puts 'Error getting repository size'
      puts e.message
      puts e.backtrace.inspect

      # Use cached size
      return se.cached_size
    end
  end


  ## Return all queries
  #def all_queries
  #  return Thing.where(type: 'Query')
  #end


  # Search for queries
  def search_for_existing_sparql_queries
    res = []
    user = @thing.user
    tmp_user = user.queries.includes(:user).where(public: false)
    tmp_pub = Thing.public_list.includes(:user).where(:type => ['Query'])
    tmp_all = tmp_user + tmp_pub

    tmp_all.each do |q|
      qt = q.query_type
      if (qt == "SELECT") || (qt == "CONSTRUCT")
        res << q
      end
    end

    return res
  end


  # Check if query links to sparql endpoint
  def query_links_to_sparql_endpoint(query, sparql_endpoint)
    return SparqlEndpointQuery.exists?({query_id: query.id, sparql_endpoint_id: sparql_endpoint.id})
  end

end
