class SparqlEndpointsController < ThingsController
  include UpwizardHelper
  include QueriesHelper
  include QuotasHelper
  include DbmsHelper
  
  wrap_parameters :sparql_endpoint, include: [:public, :name, :description, :meta_keyword_list, :license, :publish_file]

  def new
    super
    # Find valid dbms
    @dbm_entries = current_user.search_for_existing_dbms('RDF')

    # Check if quota is broken
    # This cannot know which db to check .... redirect_to quotas_path unless quota_room_for_new_sparql_count?(current_user)  ## TODO add rdf_repo in QuotasHelper
  end

  def show
    super
    @dbm_info = dbms_repo_info(@thing.rdf_repo)

    # Check if quota is broken
    # This cannot know which db to check .... redirect_to quotas_path unless quota_room_for_new_sparql_count?(current_user)  ## TODO add rdf_repo in QuotasHelper
  end

  # POST /:username/sparql_endpoints/:id/fork
  def fork
    # Check if quota is broken
    quota_ok = quota_room_for_new_sparql_count?(current_user)  ## TODO add db_account in QuotasHelper
    ## TODO Which db_account to choose?

    if quota_ok
      super                                 ## TODO add db_account in thing.fork
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
        if @thing.has_rdf_repo?
          rr = @thing.rdf_repo
          rr.upload_file_to_repository(file, file_type)
          ok = true
        else
          current_user.upload_file_ontotext_repository(rdfFile, rdfType, @thing)
          ok = true
        end
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

    dbm_id = params[:sparql_endpoint][:dbm_entries]
    dbm = Dbm.where(id: dbm_id).first

    throw 'Error DBM with different user' unless dbm.user == current_user

    # Check if quota is broken
#    unless quota_room_for_new_sparql_count?(current_user, dbm)
#      redirect_to quotas_path
#    else
      @thing = SparqlEndpoint.new(sparql_endpoint_params)
      @thing.user = current_user
      @thing.pass_parameters

      rr = RdfRepo.new
      rr.dbm = dbm
      rr.name = "RR:#{@thing.name}"
      rr.save
      @thing.rdf_repo = rr

      #Thread.new do
        puts "***** Create thread...start"
        @thing.issue_create_repo
        # @thing.uri = current_user.new_ontotext_repository(@thing)
        begin
          rr.create_repository(@thing)
          rr.save
          @upwizard = nil
          if params[:wiz_id]
            @upwizard = Upwizard.find(params[:wiz_id])
            throw "Wizard object not found!" if !@upwizard
            # Get file from wizard
            fill_default_values_if_empty
            rdfFile = @upwizard.get_current_file
            rdfType = file_ext(@upwizard.get_current_file_original_name)
            #current_user.upload_file_ontotext_repository(rdfFile, rdfType, @thing)
            @thing.rdf_repo.upload_file_to_repository(rdfFile, rdfType)
          else
            flash[:warning] = "No triple file provided."
          end
        rescue Exception => error
          flash[:error] = error.message
        end
        @upwizard.destroy if @upwizard
        ActiveRecord::Base.connection.close
        puts "***** Create thread...end"
      #end
      respond_to do |format|
        if @thing.save
          format.html { redirect_to thing_path(@thing), notice: create_notice }
          format.json { render :show, status: :created, location: thing_path(@thing) }
        else
          flash[:error] = "Could not create SPARQL endpoint. Please try again."
          format.html { redirect_to upwizard_new_path('sparql') }
          format.json { render json: @thing.errors, status: :unprocessable_entity }
        end
      end
#    end
  end

  def update
    authorize! :update, @thing
    super

    if @thing.publish_file != nil
      rdfFile = @thing.publish_file
      rdfType = file_ext(@thing.publish_file.original_filename)

      begin
        if @thing.has_rdf_repo?
          rr = @thing.rdf_repo
          rr.upload_file_to_repository(rdfFile, rdfType)
        else
          current_user.upload_file_ontotext_repository(rdfFile, rdfType, @thing)
        end
      rescue Exception => e
        flash[:error] = "Could not upload to SPARQL endpoint. Please try again."
      end
    end
  end

  def destroy
    authorize! :destroy, @thing
    super
    if @thing.has_rdf_repo?
      rr = @thing.rdf_repo
      # Do not delete backend datastores that exist in other sparql endpoint
      return if rr.things.all.size > 1
      rr.delete_repository()
      rr.destroy
    else
      # Do not delete backend datastores that exist in other sparql endpoints
      return if SparqlEndpoint.where(["metadata->>'uri' = ? AND id != ?", @thing.uri, @thing.id]).exists?

      if not @thing.uri.blank?
        current_user.delete_ontotext_repository(@thing)
      end
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

  def state
    usr = User.find_by(username: params[:username])
    @thing = SparqlEndpoint.find_by(slug: params[:slug], user: usr)
    authorize! :read, @thing
    puts @thing.state
    respond_to do |format|
      format.json { render :state, status: :ok }
    end
  end

  def url
    usr = User.find_by(username: params[:username])
    @thing = SparqlEndpoint.find_by(slug: params[:slug], user: usr)
    authorize! :read, @thing
    respond_to do |format|
      format.json { render :url, status: :ok }
    end
  end

  private
  def sparql_endpoint_params
    params.require(:sparql_endpoint).permit(:public, :name, :description, :license,
      :meta_keyword_list, :publish_file, :dbm_entries,
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
