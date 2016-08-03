class SparqlEndpointsController < ThingsController

  def new
    super
  end

  private
    def fill_default_values_if_empty
      fill_name_if_empty
      if @thing.uri.blank?
        @thing.uri = current_user.new_ontotext_repository(@thing)
      end
    end

    def sparql_endpoint_params
      params.require(:sparql_endpoint).permit(:public, :name, :description, :license, :keyword_list) ## Rails 4 strong params usage
    end

end
