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

    def data_page_set_relations(data_page)
      unless data_page.widgets.blank?
        data_page.widgets.each do |widget|
          widget.public = data_page.public
          widget.user = data_page.user
        end
      end
    end
end