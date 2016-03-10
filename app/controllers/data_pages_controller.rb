class DataPagesController < ThingsController

  def show
    super
    @widgets = @data_page.widgets
  end

  private
    def data_page_params
      params.require(:data_page).permit(
        :public, :name, :description, :license, :layout,
        widgets_attributes: [:id, :name, :url, :widget_class, :_destroy])
    end
end