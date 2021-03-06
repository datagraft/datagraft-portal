class SparqlEndpointsController < ThingsController
  include UpwizardHelper
  include QueriesHelper
  include QuotasHelper
  include DbmsHelper

  wrap_parameters :sparql_endpoint, include: [:public, :name, :description, :meta_keyword_list, :license, :publish_file, :dbm_entries]

  def new
    super
    unless quota_user_room_for_new_sparql_count?(current_user)
      redirect_to quotas_path
    else
      # Find valid dbms
      dbm_list = current_user.search_for_existing_dbms_reptype('RDF')
      @dbm_entries = quota_filter_dbm_sparql_count?(dbm_list)
    end

  end

  def show
    super
    @dbm_info = dbms_repo_info(@thing.rdf_repo)


  end

  # POST /:username/sparql_endpoints/:id/fork
  def fork
    # Check if quota is broken
    quota_ok = quota_user_room_for_new_sparql_count?(current_user)

    if quota_ok
      ## TODO Which db_account to choose?
      super                                 ## TODO add db_account in thing.fork
    else
      respond_to do |format|
        format.html { redirect_to quotas_path}
        # json error code to be discussed. :upgrade_required, :insufficient_storage
        format.json { render json: { error: flash[:error]}, status: :insufficient_storage}
      end
    end
  end

  # Receive file to be pushed to rdf_repo
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
          flash[:error] = "SparqlEndpoint is not connected to any database"
        end
      rescue => e
        puts "Could not upload to SPARQL endpoint."
        puts e.message
        puts e.backtrace.inspect
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

    begin
      ok = false
      raise 'Error bad DBM reference' if dbm == nil
      raise 'Error DBM with different user' unless dbm.user == current_user
      raise 'Error no quota on selected database' unless quota_dbm_room_for_new_sparql_count?(dbm)

      @thing = SparqlEndpoint.new(sparql_endpoint_params)
      @thing.user = current_user
      @thing.pass_parameters
      ok = @thing.save   # It is important to save @thing before using it in another Thread

      if !ok
        flash[:error] = "Could not create SPARQL endpoint. Please try again."
      else
        puts "Before - Dbm count: #{Dbm.count} ApiKey count: #{ApiKey.count}"
        Thread.new do
          puts "***** Create thread...start"
          puts "New thread - Dbm count: #{Dbm.count} ApiKey count: #{ApiKey.count}"
          begin
            @thing.issue_create_repo
            rr = RdfRepo.new
            rr.dbm = dbm
            rr.name = "RR:#{@thing.slug}"
            rr.is_public = @thing.public
            rr.save     # Save is needed before connecting to @thing
            @thing.rdf_repo = rr

            rr.create_repository(@thing)
            @upwizard = nil
            if params[:wiz_id]
              @upwizard = Upwizard.find(params[:wiz_id])
              raise "Wizard object not found!" if !@upwizard
              # Get file from wizard
              fill_default_values_if_empty
              rdfFile = @upwizard.get_current_file
              rdfType = file_ext(@upwizard.get_current_file_original_name)
              rr.upload_file_to_repository(rdfFile, rdfType)
            end
            @thing.repo_successfully_created
            rr.save

          rescue => e
            @thing.repo_error_message = e.message
            @thing.error_occured_creating_repo
            puts e.message
            puts e.backtrace.inspect

            #Cleanup
            @upwizard = nil          # Keep the upwizard for retries
            @thing.rdf_repo = nil    # Remove the RdfRepo connection from SparqlEndpoint
            rr.destroy               # Delete the RdfRepo
          end
          @thing.save                      # Save SparqlEndpoint updates
          @upwizard.destroy if @upwizard   # Delete Upwizard if we are ready with it
          ActiveRecord::Base.connection.close
          puts "***** Create thread...end"
        end
      end

    rescue => e
      @thing.error_occured_creating_repo unless @thing.nil?
      puts e.message
      ## puts e.backtrace.inspect
      flash[:error] = e.message
    end

    ##sleep(5)  # Wait some time so background thead gets ready
    puts "After sleep - Dbm count: #{Dbm.count} ApiKey count: #{ApiKey.count}"
    respond_to do |format|
      if ok
        format.html { redirect_to thing_path(@thing), notice: create_background_notice }
        format.json { render :show, status: :created, location: thing_path(@thing) }
      else
        format.html { redirect_to dashboard_path }
        format.json { render json: @thing.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize! :update, @thing
    begin
      super

      if @thing.publish_file != nil
        rdfFile = @thing.publish_file
        rdfType = file_ext(@thing.publish_file.original_filename)

        begin
          if @thing.has_rdf_repo?
            rr = @thing.rdf_repo
            rr.upload_file_to_repository(rdfFile, rdfType)
          else
            flash[:error] = "SparqlEndpoint is not connected to any database"
          end
        rescue => e
          puts e.message
          puts e.backtrace.inspect
          flash[:error] = "Could not upload to SPARQL endpoint. Please try again."
        end
      end
    rescue => e
      puts e.message
      puts e.backtrace.inspect
      flash[:error] = "Could not update SPARQL endpoint."
    end
  end

  def destroy
    authorize! :destroy, @thing

    ok = false
    begin
      super
      if @thing.has_rdf_repo?
        rr = @thing.rdf_repo
        # Do not delete backend datastores that exist in other sparql endpoint
        return if rr.things.all.size > 1
        rr.destroy
      end
      ok = true
    rescue => e
      puts e.message
      puts e.backtrace.inspect
      flash[:error] = e.message
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
      @query_error = ""
      @query_result = @query.execute_on_sparql_endpoint(@thing, current_user)
    rescue => e
      puts "Error querying RDF repository"
      ## flash[:error] = e.message
      @query_result = {
        headers: [],
        results: []
        }
      @query_error = "Error querying RDF repository #{e.message}"
    end

    if @query_result.blank?
      @results_list = []
      @query_error = "Blank result"
    else
      @results_list = @query_result[:results]
    end

    #render :partial => 'execute_query_results' if request.xhr?
    respond_to do |format|
      format.html { render :partial => 'execute_query_results' if request.xhr? }
      format.json { render 'execute_query_results' }
    end
  end

  # GET  /:username/sparql_endpoints/:id/sparql
  def sparql
    begin
      set_thing
      authorize! :read, @thing

      if @thing.has_rdf_repo?
        rr = @thing.rdf_repo
        response = rr.query_repository_proxy(request.query_parameters["query"], request.headers['Accept'])
      else
        raise "SparqlEndpoint is not connected to any database"
      end
      render :inline => response.body
    rescue => e
      puts "Error forwarding SPARQL query #{e.message}"
      render json: e.message, status: :unprocessable_entity
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
      :meta_keyword_list, :publish_file, :dbm_entries, :rdf_repo_id,
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
