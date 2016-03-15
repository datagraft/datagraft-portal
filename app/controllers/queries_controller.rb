class QueriesController < ThingsController
  private
    def destroyNotice
      "The query was successfully destroyed"
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def query_params
        params.require(:query).permit(:public, :name, :metadata, :configuration, :query, :language, :description,
          queriable_data_store_ids: [])
    end

    def query_set_relations(query)
      # This is EXTREMELY important lol
      query.queriable_data_stores.to_a.each do |qds|
        # Reject private data_stores that are not owned by the user
        # Security…
        if qds.user != query.user && !qds.public
          query.queriable_data_stores.delete(qds)
        end
      end
      # throw query.queriable_data_stores
    end
end