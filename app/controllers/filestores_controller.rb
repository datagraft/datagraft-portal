class FilestoresController < ThingsController
  
  # GET /publish
  def publish
    authorize! :create, Filestore
    @filestore = Filestore.new
  end

  # GET ':username/filestores/:id/attachment'
  def attachment
    set_thing
    redirect_to Refile.attachment_url(@thing, :file), status: :moved_permanently
  end

  protected
    # these two are useless but it's maybe faster with than without
    def virtualResource
      Filestore
    end

    def virtualResoruceName(underscore = false)
      lowercase ? 'filestore' : 'Filestore'
    end

    def virtualResourcesName
      'filestores'
    end

    def fill_name_if_empty
      @thing.name = filestore_params[:file].original_filename if @thing.name.blank?
    end
 
  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def filestore_params
      params.require(:filestore).permit([:public, :name, :description, :file])
    end
end
