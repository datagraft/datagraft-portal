class SparqlEndpointsController < ThingsController
  
  def new
    super
  end

  def publish
  end
  
  def update
    super
    username = current_user.username + '_' + current_user.ontotext_account.to_s
byebug
    current_user.update_ontotext_repository_public(@thing)

# Hack to support two submit buttons in a form with different actions
=begin
    if params[:commit] == "Execute"
      setemp = SparqlEndpoint.new
      setemp.assign_attributes(params.require(:sparql_endpoint).permit(queries_attributes: [:id, :query]))
      
      qtemp = setemp.queries.first
      qresult = qtemp.execute_on_sparql_endpoint(@thing)
      
      render :text => qresult
    else
      super
    end    
=end
  end  
  
  def destroy
    super
    
    # Do not delete backend datastores that exist in other sparql endpoints
    return if SparqlEndpoint.where(["metadata->>'uri' = ? AND id != ?", @thing.uri, @thing.id]).exists?

    if not @thing.uri.blank?
      current_user.delete_ontotext_repository(@thing)
    end
  end
  
  # Method called by the query execute form
  def execute_query
    set_thing
    authorize! :read, @thing

    @query = Query.new
    @query.name = 'Unsaved query'
    @query.query = params["execute_query"]["query"]
    @query.language = 'SPARQL'    
    
    begin
      @query_result = @query.execute_on_sparql_endpoint(@thing)
    rescue => error
      flash[:error] = error.message
      @query_result = {
        headers: [],
        results: []
      }
    end
    
    if @query_result.blank?
      @results_list = []
    else
      @results_list = @query_result[:results].paginate(:page => params[:page], :per_page => 25)
    end

    render :partial => 'execute_query_results' if request.xhr?
  end

  private
    def fill_default_values_if_empty
      fill_name_if_empty
      if @thing.uri.blank?
        @thing.uri = current_user.new_ontotext_repository(@thing)
      end
    end

    def sparql_endpoint_params
      params.require(:sparql_endpoint).permit(:public, :name, :description, :license,
        :keyword_list,
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
