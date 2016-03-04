class QueriableDataStoresController < ThingsController
  def new
    super
    # @queriable_data_store.name = 'lol' if @queriable_data_store.name.blank?
    # if params[:hosting] == 'ontotext'
      # render 'new_ontotext'
    # end
  end

  private
    def queriable_data_store_params
      params.require(:queriable_data_store).permit(:public, :name, :description, :uri, :hosting_provider)
    end
end
