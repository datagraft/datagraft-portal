class QueriesController < ThingsController

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

      @sparql_endpoint = se_user.sparql_endpoints.friendly.find(params[:execute_query][:sparql_endpoints])
    end

    # Go to selected endpoint page button_to
    #if params[:goto_sparql_endpoint_button]
    if params[:commit] == "Go to selected endpoint page"
      redirect_to thing_path(@sparql_endpoint)
    # Execute query button_to
    else
      begin
        @query_result = @query.execute_on_sparql_endpoint(@sparql_endpoint, current_user)
      rescue Execption => error
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
