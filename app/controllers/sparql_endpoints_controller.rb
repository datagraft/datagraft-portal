class SparqlEndpointsController < ThingsController
  include UpwizardHelper

  def new
    super
  end

  def publish
  end

  def create
    authorize! :create, SparqlEndpoint

    if params[:wiz_id] 
      @thing = SparqlEndpoint.new(sparql_endpoint_params)
      @thing.uri = current_user.new_ontotext_repository(@thing)
      @thing.user = current_user
      @upwizard = Upwizard.find(params[:wiz_id])
      throw "Wizard object not found!" if !@upwizard
      # Get file from wizard
      begin
        fill_default_values_if_empty
        rdfFile = @upwizard.get_current_file
        rdfType = file_ext(@upwizard.get_current_file_original_name)
        current_user.upload_file_ontotext_repository(rdfFile, rdfType, @thing)
        respond_to do |format|
          if @thing.save
            @upwizard.destroy
            format.html { redirect_to thing_path(@thing), notice: create_notice }
            format.json { render :show, status: :created, location: thing_path(@thing) }
          else
            flash[:error] = "Could not create SPARQL endpoint. Please try again."
            format.html { redirect_to upwizard_new_path('sparql') }
            format.json { render json: @thing.errors, status: :unprocessable_entity }
          end
        end
      rescue Exception => error
        flash[:error] = error.message
      end
    else
      redirect_to upwizard_new_path('sparql')
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
    @query.query = 
    if params[:existing_query] != nil
      params[:existing_query]
    else
      params["execute_query"]["query"]
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
      @results_list = @query_result[:results].paginate(:page => params[:page], :per_page => 25)
    end

    render :partial => 'execute_query_results' if request.xhr?
  end  


  private
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

  def sparql_endpoint_params_partial
    params.permit(:sparql_endpoint, :public, :name, :description, :license, :keyword_list) ## Rails 4 strong params usage
  end

end
