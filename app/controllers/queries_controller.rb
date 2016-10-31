class QueriesController < ThingsController

# Old execute method on queriable data stores replaced with sparql endpoints
=begin
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
=end

  # Method called by the query execute form
  def execute_query
    if !params[:id].blank? && !params[:username].blank?
      set_thing
      authorize! :read, @thing
      if user_signed_in? && (current_user.username == params[:username] || params[:username] == 'myassets')
        se_user = current_user
      else
        raise CanCan::AccessDenied.new("Not authorized!") if params[:username] == 'myassets'
        se_user = User.find_by_username(params[:username]) or not_found
      end

      @sparql_endpoint = se_user.sparql_endpoints.friendly.find(params[:execute_query][:sparql_slugs])
    end
    
    if @sparql_endpoint.nil?
      @query_result = {
        headers: [],
        results: []
      }
    else
      authorize! :read, @sparql_endpoint

      # HERE IS THE FUN PART
      begin
        @query_result = @query.execute(@sparql_endpoint)
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
    def destroyNotice
      "The query was successfully destroyed"
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def query_params
        params.require(:query).permit(:public, :name, :metadata, :configuration, :query, :query_type, :language, :description,
          queriable_data_store_ids: [],
          sparql_endpoint_ids: [])
    end    
  
  # It may be scary, but you should sometimes trust parameters from the internet!
    def query_params_partial
        params.permit(:query, :public, :name, :metadata, :configuration, :language, :description,
          queriable_data_store_ids: [])
    end

    def query_set_relations(query)
      # This is EXTREMELY important lol
      query.queriable_data_stores.to_a.each do |qds|
        # Reject private data_stores that are not owned by the user
        # Security…
        if qds.user != query.user && !qds.public
          query.queriable_data_stores.delete(qds)
        end
      end
      # throw query.queriable_data_stores
      
      query.sparql_endpoints.to_a.each do |se|
        if se.user != query.user && !se.public
          query.sparql_endpoints.delete(se)
        end
      end
      # throw query.sparql_endpoints  
    end
  
end
