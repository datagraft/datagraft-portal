class SparqlEndpointsController < ThingsController

  def new
    super
#    @thing.uri = current_user.new_ontotext_repository(@thing)
  end

  private
    def sparql_endpoint_params
      params.require(:sparql_endpoint).permit(:public, :name, :description, :license, :keyword_list) ## Rails 4 strong params usage
    end

end
