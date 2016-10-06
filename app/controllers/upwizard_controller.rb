class UpwizardController < ApplicationController
  include Wicked::Wizard
  steps :publish, :decide, :go_sparql, :go_filestore, :go_transform, :go_back

  def create
    @upwizard = Upwizard.find(params[:wiz_id])
    authorize! :update, @upwizard
    @upwizard.update_attributes(upwizard_params)
    fill_filedetails_if_empty
    @upwizard.save
    calculate_filetype
    #byebug
  end

  def index
    #byebug
    upwizard = Upwizard.new  # Create new wizard
    upwizard.user = current_user
    authorize! :create, upwizard
    upwizard.update_attributes(params.permit([:task]))
    upwizard.save

    goto_step = steps.first
    options = request.query_parameters

    options = options.respond_to?(:to_h) ? options.to_h : options
    options = { :controller => wicked_controller,
                :action     => 'show',
                :id         => goto_step || params[:id],
                :wiz_id     => upwizard.id,
                :only_path  => true
               }.merge options
    redirect_to url_for(options)
  end

  def destroy
    @upwizard = Upwizard.find(params[:wiz_id])
    authorize! :destroy, @upwizard
    @upwizard.destroy
  end

  def show
    @upwizard = Upwizard.find(params[:wiz_id])
    authorize! :read, @upwizard
    calculate_filetype
    #byebug
    case step
    when :go_filestore
      redirect_to_create_filestore
    when :go_sparql
      redirect_to_create_sparql_endpoint
    when :go_transform
      redirect_to_create_transformation
    when :go_back
      redirect_to_homepage
    else
      render_wizard nil, notice: 'upwizard show.'
    end
  end

  def update
    @upwizard = Upwizard.find(params[:wiz_id])
    authorize! :update, @upwizard

    # Delete the old file object if we get a new file object
    unless upwizard_params[:file] == nil
      unless @upwizard.file == nil
        @upwizard.file.delete
        @upwizard.file = nil
        @upwizard.file_size = 0
        @upwizard.file_content_type = ""
        @upwizard.original_filename = ""
      end
    end
    @upwizard.update_attributes(upwizard_params)
    fill_filedetails_if_empty
    @upwizard.save
    calculate_filetype
    #byebug
    render_wizard nil, notice: 'upwizard update.'
  end



private

  # Never trust parameters from the scary internet, only allow the white list through.
  def upwizard_params
    params.require(:upwizard).permit([:file, :task])
  end

  def redirect_to_create_filestore
    @upwizard.redirect_step = 'redirect_to_create_filestore'
    @upwizard.save
    #byebug
    options = request.query_parameters
    options = options.respond_to?(:to_h) ? options.to_h : options
    options = { :controller => 'filestores',
                :action     => 'new',
                :wiz_id     => @upwizard.id,
                :only_path  => true
               }.merge options

    #authorize! :destroy, @upwizard
    #get :index, params: { username: @user.username ,resource: 'filestores'}
    #@upwizard.destroy

    redirect_to url_for(options)
  end

  def redirect_to_create_transformation
    @upwizard.redirect_step = 'redirect_to_create_transformation not_implemented'
    @upwizard.save
    render :redirect, notice: 'Error not implemented.'
  end

  def redirect_to_create_sparql_endpoint
    @upwizard.redirect_step = 'redirect_to_create_sparql_endpoint not_implemented'
    @upwizard.save
    render :redirect, notice: 'Error not implemented.'
  end

  def redirect_to_homepage
    @upwizard.redirect_step = 'redirect_to_homepage not_implemented'
    @upwizard.save
    render :redirect,  notice: 'Error not implemented.'
  end

  def fill_filedetails_if_empty
    if @upwizard.original_filename.blank?
      # Store the original filename sections to use for upload
      @upwizard.original_filename = upwizard_params[:file].original_filename
    end
  end

  def file_ext
    unless @upwizard.original_filename.blank?
      tmp_name = @upwizard.original_filename
      ext_with_dot = File.extname(tmp_name)
      ext_no_dot = ext_with_dot.slice(1, ext_with_dot.length)
      return ext_no_dot
    else
      return nil
    end
  end

  def calculate_filetype
    @sparql_file = false
    @filestore_file = false
    ext = file_ext

    if (ext == 'rdf')
      @sparql_file =  true
    elsif (ext == 'csv')
      @filestore_file = true
    elsif (ext == 'xls')
      @filestore_file = true
    elsif (ext == 'xlsx')
      @filestore_file = true
    elsif (ext == 'tsv')
      @filestore_file = true
    end
  end

  def filestore_file?
    ext = file_ext
    if (ext == 'csv')
      return true
    elsif (ext == 'xls')
      return true
    elsif (ext == 'xlsx')
      return true
    elsif (ext == 'tsv')
      return true
    else
      return false
    end
  end

end
