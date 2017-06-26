class SparqlEndpointsController < ThingsController
  include UpwizardHelper
  include QueriesHelper
  include QuotasHelper
  wrap_parameters :sparql_endpoint, include: [:public, :name, :description, :meta_keyword_list, :license, :publish_file]

  def new
    super
    # Check if quota is broken
    redirect_to quotas_path unless quota_room_for_new_sparql_count?(current_user)
  end

  # POST /:username/sparql_endpoints/:id/fork
  def fork
    # Check if quota is broken
    quota_ok = quota_room_for_new_sparql_count?(current_user)

    if quota_ok
      super
    else
      respond_to do |format|
        format.html { redirect_to quotas_path}
        # json error code to be discussed. :upgrade_required, :insufficient_storage
        format.json { render json: { error: flash[:error]}, status: :insufficient_storage}
      end
    end
  end

  # Receive file to be pushed to ontotext
  # POST     /:username/sparql_endpoints/:id/publish
  def publish
    ok = false
    set_thing
    authorize! :update, @thing

    if params["publish_file"] != nil
      rdfFile = params["publish_file"]
      rdfType = file_ext(rdfFile.original_filename)
    begin
        current_user.upload_file_ontotext_repository(rdfFile, rdfType, @thing)
        ok = true
      rescue Exception => e
        puts "Could not upload to SPARQL endpoint."
      end
    end
    if ok
      return head(:ok)
    else
      return head(:unprocessable_entity)
    end
  end

  def create
    authorize! :create, SparqlEndpoint

    # Check if quota is broken
    redirect_to quotas_path unless quota_room_for_new_sparql_count?(current_user)

    @thing = SparqlEndpoint.new(sparql_endpoint_params)
    @thing.uri = current_user.new_ontotext_repository(@thing)
    @thing.user = current_user

    @upwizard = nil
    if params[:wiz_id]
      @upwizard = Upwizard.find(params[:wiz_id])
      throw "Wizard object not found!" if !@upwizard
      # Get file from wizard
      begin
        fill_default_values_if_empty
        rdfFile = @upwizard.get_current_file
        rdfType = file_ext(@upwizard.get_current_file_original_name)
        current_user.upload_file_ontotext_repository(rdfFile, rdfType, @thing)
      rescue Exception => error
        flash[:error] = error.message
      end
    else
      flash[:warning] = "No triple file provided."
    end

    respond_to do |format|
      if @thing.save
        @upwizard.destroy if @upwizard
        format.html { redirect_to thing_path(@thing), notice: create_notice }
        format.json { render :show, status: :created, location: thing_path(@thing) }
      else
        flash[:error] = "Could not create SPARQL endpoint. Please try again."
        format.html { redirect_to upwizard_new_path('sparql') }
        format.json { render json: @thing.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    super

    if @thing.publish_file != nil
      rdfFile = @thing.publish_file
      rdfType = file_ext(@thing.publish_file.original_filename)

      begin
        current_user.upload_file_ontotext_repository(rdfFile, rdfType, @thing)
      rescue Exception => e
        flash[:error] = "Could not upload to SPARQL endpoint. Please try again."
      end
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

  # Method called by the query execute form
  def execute_query
    set_thing
    authorize! :read, @thing

    @query = Query.new
    @query.name = 'Unsaved query'
    @query.query_string =
    if params[:existing_query] != nil
      params[:existing_query]
    else
      if params["query_string"] != nil
        params["query_string"]
      else
        params["execute_query"]["query_string"]
      end
    end
    @query.language = 'SPARQL'

    begin
      @query_result = @query.execute_on_sparql_endpoint(@thing, current_user)
    rescue Exception => error
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

    #render :partial => 'execute_query_results' if request.xhr?
    respond_to do |format|
      format.html { render :partial => 'execute_query_results' if request.xhr? }
      format.json { render 'execute_query_results' }
    end
  end


  private
  def sparql_endpoint_params
    params.require(:sparql_endpoint).permit(:public, :name, :description, :license,
      :meta_keyword_list, :publish_file,
      queries_attributes: [:id, :name, :query_string, :description, :language, :_destroy]) ## Rails 4 strong params usage
  end

  def sparql_endpoint_set_relations(se)
    return if se.queries.blank?
    se.queries.each do |query|
      query.public = se.public
      query.user = se.user
    end
  end

  def sparql_endpoint_params_partial
    params.permit(:sparql_endpoint, :public, :name, :description, :license, :meta_keyword_list) ## Rails 4 strong params usage
  end

end
