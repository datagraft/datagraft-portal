class SparqlEndpointsController < ThingsController

  def new
    super
  end

  def publish
  end
  
  def update
    if params[:commit] == "Execute"
      setemp = SparqlEndpoint.new
      setemp.assign_attributes(params.require(:sparql_endpoint).permit(queries_attributes: [:id, :query]))
      
      qtemp = setemp.queries.first
      qresult = qtemp.execute_on_sparql_endpoint(@thing)
      
      render :text => qresult
    else
      super
    end    
  end
  
  
  def destroy
    super
    
    # Do not delete backend datastores that exist in other sparql endpoints
    return if SparqlEndpoint.where(["metadata->>'uri' = ? AND id != ?", @thing.uri, @thing.id]).exists?

    if not @thing.uri.blank?
      current_user.delete_ontotext_repository(@thing)
    end
  end
  
  def execute
    if !params[:id].blank? && !params[:username].blank?
      set_thing
      authorize! :read, @thing

      if user_signed_in? && (current_user.username == params[:qds_username] || params[:qds_username] == 'myassets')
        qds_user = current_user
      else
        raise CanCan::AccessDenied.new("Not authorized!") if params[:qds_username] == 'myassets'
        qds_user = User.find_by_username(params[:qds_username]) or not_found
      end

      @queriable_data_store = qds_user.queriable_data_stores.friendly.find(params[:qds_id])
      # throw @queriable_data_store
    elsif user_signed_in?
      querying = params["querying"] || {}
      @query = @thing = Query.new
      @query.name = 'Unsaved query'
      @query.query = querying["query"]
      @query.language = querying["language"]
      @unsaved_query = true

      unless querying["queriable_data_store"].blank?
        @queriable_data_store = QueriableDataStore.friendly.find(querying["queriable_data_store"])
      end
    else
      raise CanCan::AccessDenied.new("Not authorized!")
    end

    if @queriable_data_store.nil?
      @query_result = {
        headers: [],
        results: []
      }
    else
      authorize! :read, @queriable_data_store

      # HERE IS THE FUN PART
      begin
        @query_result = @query.execute(@queriable_data_store)
      rescue => error
        flash[:error] = error.message
        # redirect_to thing_path(@query)
        # @results_list = []
        @query_result = {
          headers: [],
          results: []
        }
      end
    end

    if @query_result.blank?
      @results_list = []
    else
      @results_list = @query_result[:results].paginate(:page => params[:page], :per_page => 25)
    end
    # throw @query_result
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
  
  def execute_query(query)
    # redirect 
  end
  
end
