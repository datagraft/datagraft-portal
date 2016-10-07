class SparqlEndpointsController < ThingsController

  def new
    super
  end

  def publish
  end
  
  def destroy
    super
    
    # Do not delete backend datastores that exist in other sparql endpoints
    return if SparqlEndpoint.where(["metadata->>'uri' = ? AND id != ?", @thing.uri, @thing.id]).exists?

    if not @thing.uri.blank?
      current_user.delete_ontotext_repository(@thing)
    end
  end
  
  private
    def fill_default_values_if_empty
      fill_name_if_empty
      if @thing.uri.blank?
        @thing.uri = current_user.new_ontotext_repository(@thing)
      end
    end

    def sparql_endpoint_params
      params.require(:sparql_endpoint).permit(:public, :name, :description, :license, :keyword_list,
        queries_attributes: [:id, :name, :query, :description, :language, :_destroy]) ## Rails 4 strong params usage
    end
  
  def sparql_endpoint_set_relations(se)
    return if se.queries.blank?
    se.queries.each do |query|
      query.public = se.public
      query.user = se.user
    end 
  end
  
end
