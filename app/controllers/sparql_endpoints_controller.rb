class SparqlEndpointsController < ThingsController

  def new
    super
  end

  def sparql_endpoint_params
    params.require(:sparql_endpoint).permit(:name, :tag_list) ## Rails 4 strong params usage
  end

end
