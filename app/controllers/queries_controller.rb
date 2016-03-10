class QueriesController < ThingsController
  private
    def destroyNotice
      "The query was successfully destroyed"
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def query_params
        params.require(:query).permit(:public, :name, :metadata, :configuration, :query, :language, :description)
    end
end