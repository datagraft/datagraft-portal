class QueriesController < ThingsController
  wrap_parameters :query, include: [:public, :name, :description, :meta_keyword_list, :license, :query_string, :query_type, :language,
    sparql_endpoint_ids: []]

  def new
    search_for_existing_sparql_endpoints
    super
  end

  def edit
    search_for_existing_sparql_endpoints
    super
  end

  def create
    search_for_existing_sparql_endpoints
    super
  end

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

      ## Special hack because "wrap_params" doesnt support both :query and :execute_query
      endpoint = params[:sparql_endpoints]
      endpoint = params[:execute_query][:sparql_endpoints]  if endpoint == nil
      @sparql_endpoint = se_user.sparql_endpoints.friendly.find(endpoint)
    end

    # Go to selected endpoint page button_to
    #if params[:goto_sparql_endpoint_button]
    if params[:commit] == "Go to selected endpoint page"
      redirect_to thing_path(@sparql_endpoint)
    # Execute query button_to
    else
      timeout_error = false

      begin
        @query_result = @query.execute_on_sparql_endpoint(@sparql_endpoint, current_user)
      rescue Exception => error
        if error.class.to_s.eql?("Faraday::TimeoutError")
          timeout_error = true
        end
        flash[:error] = error.message
        @query_result = {
          headers: [],
          results: []
        }
      end

      if @query_result.blank?
        @results_list = []
      else
        @results_list = @query_result[:results]
      end

      #if timeout_error
      #  render :partial => 'execute_query_timeout' if request.xhr?
      #else
      #  render :partial => 'execute_query_results' if request.xhr?
      #end

      respond_to do |format|
        if timeout_error
          format.html { render :partial => 'execute_query_timeout' if request.xhr?}
          format.json { render 'execute_query_results' }
        else
          format.html { render :partial => 'execute_query_results' if request.xhr? }
          format.json { render 'execute_query_results' }
        end
      end



    end
  end

  private
    def destroyNotice
      "The query was successfully destroyed"
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def query_params
        from_params = params.require(:query).permit(:public, :name, :metadata, :configuration, :query_string, :query_type, :language, :description,
          queriable_data_store_ids: [],
          sparql_endpoint_ids: [])

        # If no checkboxes are ticked no array is present. Add an empty array to fix this
        unless from_params.has_key?('sparql_endpoint_ids')
          from_params = from_params.merge({'sparql_endpoint_ids' => []})
        end
        return from_params
    end

  # It may be scary, but you should sometimes trust parameters from the internet!
    def query_params_partial
        params.permit(:query, :public, :name, :metadata, :configuration, :language, :description, :query_string, queriable_data_store_ids: [], sparql_endpoint_ids: [] )
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

  # Make a list of existing sparql_endpoints. Used by view
  def search_for_existing_sparql_endpoints
    user = current_user
    if user != nil
      tmp_user = user.sparql_endpoints.includes(:user).where(public: false).where.not("name LIKE ?", "%previewed_dataset_%").sort_by(&:updated_at).reverse
    else
      tmp_user = []
    end
    tmp_pub = Thing.public_list.includes(:user).where(:type => ['SparqlEndpoint']).where.not("name LIKE ?", "%previewed_dataset_%")
    @sparql_endpoint_entries =  tmp_user + tmp_pub
    puts "******************* search_for_existing_sparql_endpoints"
    puts "@sparql_endpoint_entries: <#{@sparql_endpoint_entries.size}>"
  end


end
