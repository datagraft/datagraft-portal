class UpwizardController < ApplicationController
  include Wicked::Wizard
  steps :publish, :decide, :transform, :create_transform, :transform_select_execute, :not_implemented, :error, :go_sparql, :go_filestore, :go_back, :file_select_transform

  def create
    puts "************ upwizard create"
    @upwizard = Upwizard.find(params[:wiz_id])
    authorize! :update, @upwizard
    @upwizard.update_attributes(upwizard_params)
    fill_filedetails_if_empty
    @upwizard.save
    #calculate_filetype_and_warning
  end

  def index
    puts "************ upwizard index"
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
    puts "************ upwizard destroy"
    @upwizard = Upwizard.find(params[:wiz_id])
    authorize! :destroy, @upwizard
    @upwizard.destroy
  end

  def show
    puts "************ upwizard show"
    @upwizard = Upwizard.find(params[:wiz_id])
    authorize! :read, @upwizard
    process_state
  end

  def update
    puts "************ upwizard update"
    @upwizard = Upwizard.find(params[:wiz_id])
    authorize! :update, @upwizard

    # Delete the old file object if we get a new file object
    unless upwizard_params[:file] == nil
      unless @upwizard.file == nil
        @upwizard.file.delete
        @upwizard.file = nil
        @upwizard.file_size = 0
        @upwizard.file_content_type = nil
        @upwizard.original_filename = nil
      end
    end
    @upwizard.update_attributes(upwizard_params)
    fill_filedetails_if_empty
    process_state
  end



private
  # Never trust parameters from the scary internet, only allow the white list through.
  def upwizard_params
    params.require(:upwizard).permit([:file, :task, :radio_thing_id])
  end

  def fill_filedetails_if_empty
    if @upwizard.original_filename.blank?
      unless upwizard_params[:file] == nil
        unless upwizard_params[:file].original_filename.blank?
          # Store the original filename sections to use for upload
          @upwizard.original_filename = upwizard_params[:file].original_filename
        end
      end
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

  def search_for_existing_filestores
    case step
    when :publish
      user = @upwizard.user
      tmp = user.filestores.where(public: false)
      @thing_entries = user.filestores.where(public: true) + tmp
    end
  end

  def search_for_existing_transformations
    case step
    when :transform
      user = @upwizard.user
      tmp = user.transformations.where(public: false)
      @thing_entries = user.transformations.where(public: true) + tmp
    end
  end

  def calculate_filetype_and_warning
    @sparql_file = false
    @filestore_file = false
    ext = file_ext

    if (sparql_ext? ext)
      @sparql_file =  true
    elsif (filestore_ext? ext)
      @filestore_file = true
    end

    if (@upwizard.task == 'file')
      if (@sparql_file)
        flash[:warning] = "You have uploaded an RDF file format, which is published in a SPARQL endpoint. If you would like to continue creating a file page, please press BACK and upload a tabular file (CSV, TSV, XLS, XLSX)."
      end
    elsif (@upwizard.task == 'sparql')
      # No warnings
    else
      flash[:error] = 'This wizard does not support <'+@upwizard.task+'>'
    end

  end

  def sparql_ext? (ext)
    if (ext == 'rdf')
      return true
    else
      return false
    end
  end

  def filestore_ext? (ext)
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

  def process_state
    puts "************ upwizard process_state"
    @upwizard.trace_push step, params

    #now = Time.now
    #old_step = @upwizard.redirect_step
    #old_step = "" if old_step.blank?
    #@upwizard.redirect_step = now.to_s + " => " + step.to_s + "\n" + old_step

    calculate_filetype_and_warning
    search_for_existing_filestores
    search_for_existing_transformations

    case step
    when :publish
      handle_publish_and_render
    when :decide
      handle_decide_and_render
    when :transform
      handle_transform_and_render
    when :create_transform
      handle_create_transform
    when :transform_select_execute
      handle_transform_select_execute
    when :file_select_transform
      handle_file_select_transform_and_render
    when :go_filestore
      handle_go_filestore_and_render
    when :go_sparql
      handle_go_sparql_and_render
    when :go_back
      handle_go_back_and_render
    when :not_implemented
      handle_not_implemented_and_render
    when :error
      handle_error_and_render
    end


  end

  def handle_publish_and_render
    puts "************ upwizard handle_publish_and_render"
    #Placeholder ... Nothing to do so far
    @upwizard.save
    render_wizard
  end

  def handle_decide_and_render
    puts "************ upwizard handle_decide_and_render"
    #Placeholder ... Nothing to do so far
    @upwizard.save
    render_wizard
  end

  def handle_file_select_transform_and_render
    puts "************ upwizard handle_file_select_transform"
    unless params[:upwizard][:radio_thing_id] == nil
      # Copy file information from the selected thing
      @thing = Thing.find(@upwizard.radio_thing_id)
      unless @upwizard.file == nil
        @upwizard.file.delete
      end
      @upwizard.file = @thing.file
      @upwizard.file_size = @thing.file_size
      @upwizard.file_content_type = @thing.file_content_type
      @upwizard.original_filename = @thing.original_filename

      # Update state and process the new state
      @upwizard.trace_back_step_skip
      jump_to :transform
    else
      @upwizard.trace_back_step_skip
      jump_to :error
    end
    @upwizard.save
    render_wizard
  end

  def handle_transform_and_render
    puts "************ upwizard handle_transform"
    #Placeholder ... Nothing to do so far

    @upwizard.save
    render_wizard
  end

  def handle_create_transform
    puts "************ upwizard handle_create_transform"
    #Placeholder ... Nothing to do so far

    @upwizard.trace_back_step_skip
    jump_to :not_implemented
    @upwizard.save
    render_wizard
  end

  def handle_transform_select_execute
    puts "************ upwizard handle_transform_select_execute"

    unless params[:upwizard][:radio_thing_id] == nil
      # Copy file information from the selected thing
      @thing = Thing.find(@upwizard.radio_thing_id)
      # TODO Got a transformation ... what to do next?

      # Update state and process the new state
      @upwizard.trace_back_step_skip
      jump_to :not_implemented
    else
      @upwizard.trace_back_step_skip
      jump_to :error
    end
    @upwizard.save
    render_wizard
  end

  # Pass this upwizard object over to a new filestore object
  def handle_go_filestore_and_render
    puts "************ upwizard handle_go_filestore"

    @upwizard.save
    options = request.query_parameters
    options = options.respond_to?(:to_h) ? options.to_h : options
    options = { :controller => 'filestores',
                :action     => 'new',
                :wiz_id     => @upwizard.id,
                :only_path  => true
               }.merge options

    redirect_to url_for(options)
  end

  def handle_go_sparql_and_render
    puts "************ upwizard handle_go_sparql"

    @upwizard.save
    options = request.query_parameters
    options = options.respond_to?(:to_h) ? options.to_h : options
    options = { :controller => 'sparql_endpoints',
                :action     => 'new',
                :wiz_id     => @upwizard.id,
                :only_path  => true
               }.merge options

    redirect_to url_for(options)
  end

  def handle_go_back_and_render
    puts "************ upwizard handle_go_back"
    back_step = @upwizard.trace_pop_back_step

    jump_to back_step unless back_step == nil
    @upwizard.save
    render_wizard
  end

  def handle_go_cancel_and_render
    authorize! :destroy, @upwizard
    @upwizard.destroy
    redirect_to dashboard_path
  end

  def handle_not_implemented_and_render
    puts "************ upwizard handle_not_implemented"
    #Will show a debug page
    #Nothing more to do so far...
    @upwizard.trace_back_step_skip
    @upwizard.save
    render_wizard
  end

  def handle_error_and_render
    puts "************ upwizard handle_not_implemented"
    #Will show a debug page
    #Nothing more to do so far...
    @upwizard.trace_back_step_skip
    @upwizard.save
    render_wizard
  end

end
