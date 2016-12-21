class FilestoresController < ThingsController

  # Deprecated after introduction of upwizard
  # Receive a file attachement
  # GET /publish
  def publish
    authorize! :create, Filestore
    @filestore = Filestore.new
  end

  # Fetch a file attached to the filestore
  # GET ':username/filestores/:id/attachment'
  def attachment
    set_thing
    redirect_to Refile.attachment_url(@thing, :file), status: :moved_permanently
  end

  # View the first rows of the attached file
  # GET ':username/filestores/:id/preview'
  def preview
    puts "************ filestore preview"
    set_thing
    authorize! :read, @thing
    @preview_tab_obj = nil
    if !@thing.file.nil? and @thing.file.exists?
      @preview_text = "This file is available"
      open_spreadsheet(@thing.upload_format, @thing.file)
    else
      @preview_text = "This file is NOT available"
    end
  end

  # Create a permanent filestore. Called from a new_form
  # If :wiz_id is present the file attaced to upwizard is transferred to filestorage
  def create
    puts "************ filestore create"
    super

    unless params[:wiz_id] == nil
      begin
        @upwizard = Upwizard.find(params[:wiz_id])
      rescue Exception => e
        puts e.message
        puts e.backtrace.inspect
        throw e
      end
      @thing.file = @upwizard.get_current_file
      @thing.file_size = @upwizard.get_current_file.size
      throw "Wizard corrupted - unknown file type" if !@upwizard.current_file_type
      throw "Wizard corrupted - wrong file type" if @upwizard.current_file_type == 'graph'
      @thing.file_content_type = @upwizard.current_file_type
      @thing.original_filename = @upwizard.original_filename ? @upwizard.original_filename : @upwizard.get_current_file_original_name
      fill_default_values_if_empty
      @thing.save
      @upwizard.destroy
    end
  end

  # Create a temporary filestore object and pass it to a new_form
  # If :wiz_id is present the file attaced to upwizard is shown in the form
  # The upwizard lives on as owner of the attaced file until create is called
  # GET /:username/filestores/new
  # GET /:username/filestores/new/:wiz_id
  def new
    puts "************ filestore new"
    super

    unless params[:wiz_id] == nil
      @upwizard = Upwizard.find(params[:wiz_id])
      @thing.original_filename = @upwizard.get_current_file_original_name
    end
    fill_default_values_if_empty
  rescue ActiveRecord::RecordNotFound
    redirect_to upwizard_new_path('file')
  end

  # Show an existing filestore entry
  # GET ':username/filestores/:id'
  def show
    puts "************ filestore show"
    super
    @ext = @thing.upload_format
    #@preview_tab_obj = nil
    #if !@thing.file.nil? and @thing.file.exists?
    #  @preview_text = "This file is available"
    #  open_spreadsheet(@thing.upload_format, @thing.file)
    #else
    #  @preview_text = "This file is NOT available"
    #end
  end

  def edit
    super
    @ext = @thing.upload_format
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

  # Copy fileinformation passed from the form but not part of the file obj.
  def fill_name_if_empty
    #@thing.name = filestore_params[:file].original_filename if @thing.name.blank?

    unless @thing.original_filename == nil
      @thing.name = @thing.original_filename if @thing.name.blank?

      if @thing.upload_filename.blank?
        # Store the original filename sections to use for upload
        #tmp_name = filestore_params[:file].original_filename
        tmp_name = @thing.original_filename
        format_with_dot = File.extname(tmp_name)
        filename_base = File.basename(tmp_name, format_with_dot)
        @thing.upload_filename = filename_base

        format_no_dot = format_with_dot.slice(1, format_with_dot.length)
        @thing.upload_format = format_no_dot  if  @thing.upload_format.blank?
      end
      @ext = @thing.upload_format
    end
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def filestore_params
    params.require(:filestore).permit([:public, :name, :description, :meta_keyword_list, :separator, :license, :file])
  end

  def filestore_params_partial
    params.permit(:filestore, [:public, :name, :description, :meta_keyword_list, :separator, :license, :file])
  end

  # Open an attached file if it is a spreadsheet
  # Return an object with tabular information usable for preview
  def open_spreadsheet(format, file)
    begin
      file_path = file.download.path
      case format
      when 'csv' then
        sep_start = @thing.separator.split('(')[0]
        case sep_start
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
      when 'xls' then
        @preview_text = "Decoded"
        @preview_tab_obj = Roo::Excel.new(file_path, file_warning: :ignore)
      when 'xlsx' then
        @preview_text = "Decoded"
        @preview_tab_obj = Roo::Excelx.new(file_path, file_warning: :ignore)
      else
        @preview_text = "Unknown file format: #{format}"
      end

      unless @preview_tab_obj == nil
        #Test if access of the object throws exception
        to = @preview_tab_obj
        rows = to.last_row
        rows = 10 if rows > 10
        1.upto(rows) do |i|
          1.upto(to.last_column) do |j|
            cell_content = to.cell(i,j)
          end
        end
      end
    rescue Exception => e
      puts "File decoding failed preview"
      puts e.message
      puts e.backtrace.inspect
      @preview_text = "Decode of filetype <#{format}> failed with message <#{e.message}>. Try to download the file to check content."
      @preview_tab_obj = nil
    end
  end

end
