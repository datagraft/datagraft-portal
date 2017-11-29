class QueriesController < ThingsController
  wrap_parameters :query, include: [:public, :name, :description, :meta_keyword_list, :license, :query_string, :query_type, :language,
    sparql_endpoint_ids: [], arango_db_ids: []]

  def new
    search_for_existing_sparql_endpoints
    search_for_existing_arango_dbs
    super
  end

  def edit
    search_for_existing_sparql_endpoints
    search_for_existing_arango_dbs
    super
  end

  def create
    search_for_existing_sparql_endpoints
    search_for_existing_arango_dbs
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
      @sparql_endpoint = nil
      @sparql_endpoint = se_user.sparql_endpoints.friendly.find(endpoint) if endpoint != nil
      arango_db = params[:arango_dbs]
      arango_db = params[:execute_query][:arango_dbs]  if arango_db == nil
      @arango_db = nil
      @arango_db = se_user.arango_dbs.friendly.find(arango_db) if arango_db != nil
    end

    # Go to selected endpoint page button_to
    if params[:commit] == "Go to selected endpoint page" #goto_sparql_endpoint_button
      redirect_to thing_path(@sparql_endpoint)

    elsif params[:commit] == "Go to selected database page" #goto_selected_database_button
      redirect_to thing_path(@arango_db)

    else # Execute query button_to
      timeout_error = false

      begin
        @query_error =  ""
        @query_result = @query.execute_on_sparql_endpoint(@sparql_endpoint, current_user) unless @sparql_endpoint.nil?
        @query_result = @query.execute_on_arango_db(@arango_db, current_user) unless @arango_db.nil?

      rescue => e
        puts "Error executing query: #{e.message}"
        ##flash[:error] = e.message
        @query_result = {
          headers: [],
          results: []
        }
        @query_error =  "Error querying RDF repository #{e.message}"
      end

      if @query_result.blank?
        @results_list = []
        @query_error = "Blank result"
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
          queriable_data_store_ids: [], sparql_endpoint_ids: [], arango_db_ids: [])

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
      ##query.queriable_data_stores.to_a.each do |qds|
      ##  # Reject private data_stores that are not owned by the user
      ##  # Security…
      ##  if qds.user != query.user && !qds.public
      ##    query.queriable_data_stores.delete(qds)
      ##  end
      ##end
      ### throw query.queriable_data_stores

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

  # Make a list of existing arango_dbs. Used by view
  def search_for_existing_arango_dbs
    user = current_user
    if user != nil
      tmp_user = user.arango_dbs.includes(:user).where(public: false).where.not("name LIKE ?", "%previewed_dataset_%").sort_by(&:updated_at).reverse
    else
      tmp_user = []
    end
    tmp_pub = Thing.public_list.includes(:user).where(:type => ['ArangoDb']).where.not("name LIKE ?", "%previewed_dataset_%")
    @arango_db_entries =  tmp_user + tmp_pub
    puts "******************* search_for_existing_arango_dbs"
    puts "@arango_db_entries: <#{@arango_db_entries.size}>"
  end


end
