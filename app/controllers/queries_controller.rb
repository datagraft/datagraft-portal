class QueriesController < ThingsController

  def execute
    set_thing

    authorize! :read, @thing

    if user_signed_in? && (current_user.username == params[:qds_username] || params[:qds_username] == 'myassets')
      qds_user = current_user
    else
      raise CanCan::AccessDenied.new("Not authorized!") if params[:qds_username] == 'myassets'
      qds_user = User.find_by_username(params[:qds_username]) or not_found
    end

    @queriable_data_store = qds_user.queriable_data_stores.friendly.find(params[:qds_id])

    authorize! :read, @queriable_data_store

    # HERE IS THE FUN PART
    begin
      @query_result = @thing.execute(@queriable_data_store)
    rescue => error
      flash[:error] = error.message
      redirect_to thing_path(@query)
    end

    @results_list = @query_result[:results].paginate(:page => params[:page], :per_page => 10)
    # throw @query_result
  end

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