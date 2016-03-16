class DataPagesController < ThingsController

  def show
    super
    @widgets = @data_page.widgets
    @queriable_data_stores = @data_page.queriable_data_stores
      .eager_load([:queriable_data_store_queries, :queries, :user])
      .order(stars_count: :desc, created_at: :desc)
  end

  private
    def data_page_params
      params.require(:data_page).permit(
        :public, :name, :description, :license, :layout,
        widgets_attributes: [:id, :name, :url, :widget_class, :_destroy],
        queriable_data_store_ids: [])
    end

    def data_page_set_relations(data_page)
      unless data_page.widgets.blank?
        data_page.widgets.each do |widget|
          widget.public = data_page.public
          widget.user = data_page.user
        end
      end

      # This is EXTREMELY important lol
      data_page.queriable_data_stores.to_a.each do |qds|
        # Reject private data_stores that are not owned by the user
        # Security…
        if qds.user != data_page.user && !qds.public
          .queriable_data_stores.delete(qds)
        end
      end
    end
end