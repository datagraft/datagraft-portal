class QueriableDataStoresController < ThingsController
  def new
    super
    # @queriable_data_store.name = 'lol' if @queriable_data_store.name.blank?
    @queriable_data_store.hosting_provider = params[:hosting_provider] if params[:hosting_provider]
  end

  def publish
  end

  private
    def queriable_data_store_params
      params.require(:queriable_data_store).permit(:public, :name, :description, :uri, :hosting_provider,
          queries_attributes: [:id, :name, :query, :description, :language, :_destroy])
    end

    def queriable_data_store_set_relations(qds)
      return if qds.queries.blank?
      qds.queries.each do |query|
        query.public = qds.public
        query.user = qds.user
      end 
    end
end
