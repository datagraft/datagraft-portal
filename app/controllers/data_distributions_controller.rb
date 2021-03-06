class DataDistributionsController < ThingsController

  # GET /publish
  def publish
    authorize! :create, DataDistribution
    @data_distribution = DataDistribution.new
  end

  # GET ':username/data_distributions/:id/attachment'
  def attachment
    set_thing
    redirect_to Refile.attachment_url(@thing, :file), status: :moved_permanently
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
    if data_distribution_params[:file] 
      @thing.name = data_distribution_params[:file].original_filename if @thing.name.blank?
    else
      puts "ERROR: no file in distribution! (It's ok though...)"
      @thing.name = Bazaar.object
    end
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def data_distribution_params
    params.require(:data_distribution).permit([:public, :name, :description, :file])
  end

  def data_distribution_params_partial
    params.permit(:data_distribution, :public, :name, :description, :file)
  end
end
