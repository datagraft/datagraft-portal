class SparqlEndpointsController < ThingsController
  include UpwizardHelper
  
  def new
    super
  end

  def publish
  end
  
=begin
  def update
    attr_name = 'public'
    old_value = @thing.read_attribute(attr_name)
    super
    new_value = @thing.read_attribute(attr_name)
byebug
    # Update public/private property if changed
    if new_value != old_value
      current_user.update_ontotext_repository_public(@thing)    
    end
  end 
=end
  
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

      unless params[:wiz_id] == nil
        @upwizard = Upwizard.find(params[:wiz_id])
        
        # Get file from wizard
        begin
          rdfFile = @upwizard.get_current_file
          rdfType = file_ext(@upwizard.get_current_file_original_name)
          current_user.upload_file_ontotext_repository(rdfFile, rdfType, @thing)
        rescue => error
          flash[:error] = error.message
        end

        # Delete wizard
        @upwizard.destroy
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
      
    def sparql_endpoint_params_partial
      params.permit(:sparql_endpoint, :public, :name, :description, :license, :keyword_list) ## Rails 4 strong params usage
    end

end
