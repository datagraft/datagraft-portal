class DataDistributionsController < ThingsController
  
  # GET /publish
  def publish
    authorize! :create, DataDistribution
    @data_distribution = DataDistribution.new
  end

  protected
    # these two are useless but it's maybe faster with than without
    def virtualResource
      DataDistribution
    end

    def virtualResoruceName(underscore = false)
      lowercase ? 'data_distribution' : 'DataDistribution'
    end

    def virtualResourcesName
      'data_distributions'
    end

    def fill_name_if_empty
      @thing.name = data_distribution_params[:file].original_filename if @thing.name.blank?
    end
 
  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def data_distribution_params
      params.require(:data_distribution).permit([:public, :name, :description, :file])
    end
end
