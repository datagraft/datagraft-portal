class UpwizardsController < ApplicationController
  include UpwizardHelper
  include Wicked::Wizard
  steps :publish, :decide, :transform, :create_transform, :save_transform, :transform_select_execute, :fill_sparql_endpoint, :fill_filestore, :not_implemented, :error, :go_sparql, :go_filestore, :go_back, :file_select_transform

  # Receive new file attacement from form
  # Step in the wizard is indicated by :id. Not used by this method
  # POST     /:username/upwizards/:id/:wiz_id
  def create
    puts "************ upwizard create"
    @upwizard = Upwizard.find(params[:wiz_id])
    authorize! :update, @upwizard

    copy_additional_fileinfo
    @upwizard.update_attributes(upwizard_params)

    @upwizard.save

    #calculate_filetype_and_warning
  end

  # List all upwizard objects
  # GET      /:username/upwizards
  def index

    if user_signed_in? && (current_user.username == params[:username] )
      @user = User.find_by_username(params[:username])
    else
      raise CanCan::AccessDenied.new("Not authorized!")
    end

    @upwizard_entries = @user.upwizards

  end

  # Create a new upwizard with a specific task.
  #   Valid tasks are 'file' and 'sparql'
  # GET      /:username/upwizards/new/:task
  def new
    puts "************ upwizard new"

    #Check if known task
    task = params['task']
    known_task = false
    known_task = true if task == 'file'
    known_task = true if task == 'sparql'


    if known_task
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
  end

  # Delete a given upwizard including attaced file
  # DELETE   /:username/upwizards/:wiz_id
  def destroy
    puts "************ upwizard destroy"
    @upwizard = Upwizard.find(params[:wiz_id])
    @user = @upwizard.user
    authorize! :destroy, @upwizard
    @upwizard.destroy

    redirect_to upwizard_index_path(@user)
  end

  # Show the step in the wizard
  # Step in the wizard is indicated by :id.
  # GET      /:username/upwizards/:id/:wiz_id
  def show
    puts "************ upwizard show"
    @upwizard = Upwizard.find(params[:wiz_id])

    authorize! :read, @upwizard
    process_state
  end

  # Show trace information for this wizard
  # Step in the wizard is indicated by :id. Not used by this method
  # GET      /:username/upwizards/:id/:wiz_id/debug
  def debug
    puts "************ upwizard debug"
    @upwizard = Upwizard.find(params[:wiz_id])
    authorize! :read, @upwizard
  end

  # Update with params from form
  # Show the step in the wizard
  # Step in the wizard is indicated by :id.
  # PUT      /:username/upwizards/:id/:wiz_id
  # PATCH    /:username/upwizards/:id/:wiz_id
  def update
    puts "************ upwizard update"
    @upwizard = Upwizard.find(params[:wiz_id])
    authorize! :update, @upwizard

    copy_additional_fileinfo
    @upwizard.update_attributes(upwizard_params)
    process_state
  end

  # Redirect to the attached file of the upwizard object
  # GET /:username/upwizards/:id/attachment
  def attachment
    @upwizard = Upwizard.find(params[:wiz_id])
    authorize! :read, @upwizard
    location = Refile.attachment_url(@upwizard, :file)
    if location.nil?
      render :json => {
        error: 'The wizard doesn\'t contain a file'
      }, :status => 404
    else
      redirect_to location, status: :moved_permanently
    end
  end

protected


private

  def use_transformed_file?
    ret = false
    unless transformed_file_type.blank?
      if transformed_file_type == 'rdf'
        ret = true
      elsif transformed_file_type == 'csv'
        ret = true
      end
    end
    return ret
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def upwizard_params
    params.require(:upwizard).permit([:file, :transformed_file, :task, :username, :radio_thing_id])
  end

  # Copy additional fileinformation from form
  def copy_additional_fileinfo
    unless upwizard_params[:file] == nil
      @upwizard.original_filename = nil
      unless upwizard_params[:file].original_filename.blank?
        @upwizard.original_filename = upwizard_params[:file].original_filename
      end
    end
  end


  # Extract file extension from filename
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

  # Make a list of existing filestores. Used by view
  def search_for_existing_filestores
    case step
    when :publish
      user = @upwizard.user
      tmp_user = user.filestores.includes(:user).where(public: false)
      tmp_pub = Thing.public_list.where(:type => ['Filestore'])
      @thing_entries =  tmp_pub + tmp_user
    end
  end

  # Make a list of existing transformations. Used by view
  def search_for_existing_transformations
    case step
    when :transform
      user = @upwizard.user
      tmp_user = user.transformations.includes(:user).where(public: false)
      tmp_pub = Thing.public_list.where(:type => ['Transformation'])
      @thing_entries =  tmp_pub + tmp_user
    end
  end

  # Check if file is compatible with task. Used by view
  def calculate_filetype_and_warning
    @sparql_file = false
    @filestore_file = false
    @ext = file_ext

    if (sparql_ext? @ext)
      @sparql_file =  true
    elsif (filestore_ext? @ext)
      @filestore_file = true
    end

    if (@upwizard.task == 'file')
      if (@sparql_file)
        if (step == :decide)
          flash[:warning] = "You have uploaded an RDF file format, which is published in a SPARQL endpoint.<BR> If you would like to continue creating a file page, please press BACK and upload a tabular file (CSV, TSV, XLS, XLSX)."
        end
      end
    elsif (@upwizard.task == 'sparql')
      # No warnings
    else
      flash[:error] = 'This wizard does not support <'+@upwizard.task+'>'
    end

  end

  # Is extension compatible for task sparql
  def sparql_ext? (ext)
    if (ext == 'rdf')
      return true
    else
      return false
    end
  end

  # Is extension compatible for task file
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

  # Do handle next state request
  # Push trace info onto the stack
  # Render suitable view as a response
  def process_state
    puts "************ upwizard process_state"
    @curr_step = step

    # TODO this fails weirdly
    unless step == :save_transform
      @upwizard.trace_push step, params
    end

    now = Time.now
    old_step = @upwizard.redirect_step
    old_step = "" if old_step.blank?
    @upwizard.redirect_step = now.to_s + " => " + step.to_s + "\n" + old_step

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
      handle_create_transform_and_render
    when :save_transform
      handle_save_transform_and_render
    when :transform_select_execute
      handle_transform_select_execute_and_render
    when :fill_sparql_endpoint
      handle_fill_sparql_endpoint_and_render
    when :fill_filestore
      handle_fill_filestore_and_render
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

  def handle_create_transform_and_render
    puts "************ upwizard handle_create_transform"
    #Placeholder ... Nothing to do so far

    @upwizard.trace_back_step_skip
    # jump_to :not_implemented
    @upwizard.save

    @grafterizerPath = Rails.configuration.grafterizer['publicPath']
    # Make sure the wiz_id is an number, to prevent XSS
    @distributionId = "upwizards--" + (params[:wiz_id].to_i.to_s)


    render_wizard
  end

  def handle_save_transform_and_render
    puts "************ upwizard handle_save_transform"
    respond_to do |format|
      if @upwizard.save
        format.html { jump_to :not_implemented }
        format.json { head :no_content }
      else
        format.html { jump_to :create_transform }
        format.json { render json: @upwizard.errors, status: :unprocessable_entity }
      end
    end
    render_wizard
  end

  def handle_transform_select_execute_and_render
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

  # Pass the transformed tabular object over to a new filestore object
  def handle_fill_filestore_and_render
    puts "************ upwizard handle_fill_filestore"

    @upwizard.transformed_file_type = 'csv'
    @upwizard.trace_back_step_skip
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

  # Pass the transformed graph object over to a new sparql endpoint
  def handle_fill_sparql_endpoint_and_render
    puts "************ upwizard handle_fill_sparql_endpoint"

    @upwizard.transformed_file_type = 'rdf'
    @upwizard.trace_back_step_skip
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

  # Pass the uploaded object over to a new filestore object
  def handle_go_filestore_and_render
    puts "************ upwizard handle_go_filestore"

    @upwizard.transformed_file_type = nil  # Dont use the transformed file
    @upwizard.trace_back_step_skip
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

  # Pass the uploaded object over to a new sparql endpoint object
  def handle_go_sparql_and_render
    puts "************ upwizard handle_go_sparql"

    @upwizard.transformed_file_type = nil  # Dont use the transformed file
    @upwizard.trace_back_step_skip
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
