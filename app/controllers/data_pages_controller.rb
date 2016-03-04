class DataPagesController < ThingsController

  private
    def data_page_params
      params.require(:data_page).permit(:public, :name, :description)
    end
end