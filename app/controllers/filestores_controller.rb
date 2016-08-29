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

  def show
    super
    @preview_tab_obj = nil
    if @thing.file.exists?
      @preview_text = "This file is available"
      open_spreadsheet(@thing.name, @thing.file)
    else
      @preview_text = "This file is NOT available"
    end
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
      params.require(:filestore).permit([:public, :name, :description, :keywords, :separator, :license, :file, :keyword_list])
    end

    def open_spreadsheet(file_name_with_ext, file)
      file_path = file.download.path
      case File.extname(file_name_with_ext)
      when '.csv' then
        case @thing.separator
        when "COMMA" then
          sep = ","
        when "SEMI" then
          sep = ";"
        when "TAB" then
          sep = "\t"
        else
          sep = ","
        end
        @preview_text = "Decoded"
        @preview_tab_obj = Roo::CSV.new(file_path, { csv_options: {col_sep: sep}, file_warning: :ignore})
        @preview_tab_obj
      when '.xls' then
        @preview_text = "Decoded"
        @preview_tab_obj = Roo::Excel.new(file_path, file_warning: :ignore)
      when '.xlsx' then
        @preview_text = "Decoded"
        @preview_tab_obj = Roo::Excelx.new(file_path, file_warning: :ignore)
      else
        @preview_text = "Unknown file type: #{file_name_with_ext}"
      end
    end

end
