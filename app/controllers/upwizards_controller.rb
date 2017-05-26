class UpwizardsController < ApplicationController
  include QuotasHelper
  include UpwizardHelper
  include Wicked::Wizard
  steps :publish, :transform, :create_transform, :save_transform, :transform_select_execute, :transform_select_preview, :transform_direct, :fill_sparql_endpoint, :fill_filestore, :error, :go_sparql, :go_filestore, :file_select_transform

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
    puts "************ upwizard index"

    if user_signed_in? && (current_user.isadmin)
      ##@user = User.find_by_username(params[:username])
      ##@upwizard_entries = @user.upwizards
      @upwizard_entries = Upwizard.all
      render
    else
      redirect_error_to_dashboard('Error wizard index is only accesible for administrators')
    end


  end

  # Create a new upwizard with a specific task.
  #   Valid tasks are 'file' and 'sparql'
  # GET      /:username/upwizards/new/:task
  def new
    puts "************ upwizard new"

    if user_signed_in?
      #Check if known task
      task = params['task']
      known_task = false
      quota_full = false
      if task == 'file'
        known_task = true
        quota_full = true unless quota_room_for_new_file_count?(current_user)
      end
      if task == 'sparql'
        known_task = true
        quota_full = true unless quota_room_for_new_sparql_count?(current_user)
      end

      if quota_full
        redirect_to quotas_path

      elsif known_task
        begin
          @upwizard = Upwizard.new  # Create new wizard
          @upwizard.user = current_user

          authorize! :create, @upwizard
          @upwizard.update_attributes(params.permit([:task]))
          @upwizard.save

          respond_to do |format|
            format.html {
              goto_step = steps.first
              options = request.query_parameters

              options = options.respond_to?(:to_h) ? options.to_h : options
              options = { :controller => wicked_controller,
                :action     => 'show',
                :id         => goto_step || params[:id],
                :wiz_id     => @upwizard.id,
                :only_path  => true
                }.merge options
              flash[:notice] = "New wizard is started"
              redirect_to url_for(options)
            }
            format.json { render :show_json, status: :ok }
          end

        rescue Exception => e
          redirect_error_to_dashboard("Wizard create failed.", e)
        end
      else
        redirect_error_to_dashboard("Wizard cannot be created with task = "+task)
      end
    else
      redirect_error_to_dashboard('Error user not signed in')
    end

  end

  # Delete a given upwizard including attaced file
  # DELETE   /upwizards/:wiz_id
  def destroy
    puts "************ upwizard destroy"
    begin
      @upwizard = Upwizard.find(params[:wiz_id])
      authorize! :destroy, @upwizard
      @upwizard.destroy
      flash[:notice] = "Wizard #{params[:wiz_id]} is deleted"
      redirect_to upwizard_index_path
    rescue Exception => e
      unless (@upwizard)
        puts "Wizard #{params[:wiz_id]} does not exist!"
      end
      redirect_error_to_dashboard('Error deleting wizard.', e)
    end

  end

  # Show the step in the wizard
  # Step in the wizard is indicated by :id.
  # GET      /:username/upwizards/:id/:wiz_id
  def show
    puts "************ upwizard show"
    begin
      @upwizard = Upwizard.find(params[:wiz_id])
      authorize! :read, @upwizard
      process_state
    rescue Exception => e
      unless (@upwizard)
        puts "Wizard #{params[:wiz_id]} does not exist!"
      end
      redirect_error_to_dashboard('Error showing wizard.', e)
    end
  end

  # Show the content of the wizard
  # GET      /:username/upwizards/:wiz_id
  def show_json
    puts "************ upwizard show_json"
    begin
      @upwizard = Upwizard.find(params[:wiz_id])
      authorize! :read, @upwizard

      respond_to do |format|
        format.html { redirect_error_to_dashboard('Error URL not supported for HTML.') }
        format.json { render :show_json, status: :ok }
      end
    rescue Exception => e
      unless (@upwizard)
        puts "Wizard #{params[:wiz_id]} does not exist!"
      end
      redirect_error_to_dashboard('Error showing wizard.', e)
    end
  end

  # Show trace information for this wizard
  # Step in the wizard is indicated by :id. Not used by this method
  # GET      /:username/upwizards/:id/:wiz_id/debug
  def debug
    puts "************ upwizard debug"
    begin
      @upwizard = Upwizard.find(params[:wiz_id])
      authorize! :read, @upwizard
    rescue Exception => e
      unless (@upwizard)
        puts "Wizard #{params[:wiz_id]} does not exist!"
      end
      redirect_error_to_dashboard('Error showing wizard debug info.', e)
    end
  end

  # Update with params from form
  # Show the step in the wizard
  # Step in the wizard is indicated by :id.
  # PUT      /:username/upwizards/:id/:wiz_id
  # PATCH    /:username/upwizards/:id/:wiz_id
  def update
    puts "************ upwizard update"
    begin
      @upwizard = Upwizard.find(params[:wiz_id])
      authorize! :update, @upwizard

      copy_additional_fileinfo
      @upwizard.update_attributes(upwizard_params)
      process_state
    rescue Exception => e
      unless (@upwizard)
        puts "Wizard #{params[:wiz_id]} does not exist!"
      end
      redirect_error_to_dashboard('Error updating wizard.', e)
    end
  end

  # Redirect to the attached file of the upwizard object
  # GET /:username/upwizards/:id/attachment
  def attachment
    puts "************ upwizard attachement"
    begin
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
    rescue Exception => e
      unless (@upwizard)
        puts "Wizard #{params[:wiz_id]} does not exist!"
      end
      puts e.message
      puts e.backtrace.inspect
      render :json => {
        error: e.message
        }, :status => 404
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def upwizard_params
    params.require(:upwizard).permit([:file, :transformed_file, :task, :username, :radio_thing_id])
  end

  def redirect_error_to_dashboard(txt, e=nil)
      puts txt
      if (e == nil)
        flash[:error] = txt
      else
        puts e.message
        puts e.backtrace.inspect
        flash[:error] = txt + ' Cause: ' + e.message
      end
      respond_to do |format|
        format.html { redirect_to dashboard_path }
        format.json { render :json => { :errors => flash[:error]}, status: :unprocessable_entity }
      end

  end

  def jump_error_to_state_and_render(txt, state, e=nil)
      puts txt
      if (e == nil)
        flash[:error] = txt
      else
        puts e.message
        puts e.backtrace.inspect
        flash[:error] = txt + ' Cause: ' + e.message
      end
      respond_to do |format|
        format.html {
          jump_to state
          render_wizard
        }
        format.json { render :json => { :errors => flash[:error]}, status: :unprocessable_entity }
      end
  end

  # Copy additional fileinformation from form
  def copy_additional_fileinfo
    unless upwizard_params[:file] == nil
      @upwizard.original_filename = nil
      unless upwizard_params[:file].original_filename.blank?
        @upwizard.original_filename = upwizard_params[:file].original_filename

        ext = file_ext(@upwizard.original_filename)
        if filestore_ext?(ext)
          @upwizard.current_file_type = 'tabular'
        elsif sparql_ext?(ext)
          @upwizard.current_file_type = 'graph'
        else
          @upwizard.current_file_type = ''
        end
      end
    end
  end


  # Make a list of existing filestores. Used by view
  def search_for_existing_filestores
    case step
    when :publish
      user = @upwizard.user
      tmp_user = user.filestores.includes(:user).where(public: false).where.not("name LIKE ?", "%previewed_dataset_%").sort_by(&:updated_at).reverse
      tmp_pub = Thing.public_list.includes(:user).where(:type => ['Filestore']).where.not("name LIKE ?", "%previewed_dataset_%")
      @thing_entries =  tmp_user + tmp_pub
    end
  end

  # Make a list of existing transformations. Used by view
  def search_for_existing_transformations
    case step
    when :transform
      user = @upwizard.user
      tmp_user = user.transformations.includes(:user).where(public: false).sort_by(&:updated_at).reverse
      tmp_pub = Thing.public_list.includes(:user).where(:type => ['Transformation'])
      @thing_entries =  tmp_user + tmp_pub
    end
  end

  # Check if file is compatible with task. Used by view
  def calculate_filetype_and_warning
    @sparql_file = false
    @filestore_file = false
    @ext = file_ext(@upwizard.original_filename)

    if (sparql_ext? @ext)
      @sparql_file =  true
    elsif (filestore_ext? @ext)
      @filestore_file = true
    end

    ##if (@upwizard.task == 'file')
    ##  if (@sparql_file)
    ##    if (step == :decide)
    ##      flash[:warning] = "You have uploaded an RDF file format, which is published in a SPARQL endpoint.<BR> If you would like to continue creating a file page, please press BACK and upload a tabular file (CSV, TSV, XLS, XLSX)."
    ##    end
    ##  end
    ##elsif (@upwizard.task == 'sparql')
    ##  # No warnings
    ##else
    ##  flash[:error] = 'This wizard does not support <'+@upwizard.task+'>'
    ##end

  end

  # Is extension compatible for task sparql
  def sparql_ext? (ext)
    if (ext == 'rdf')
      return true
    elsif (ext == 'nt')
      return true
    elsif (ext == 'ttl')
      return true
    elsif (ext == 'n3')
      return true
    elsif (ext == 'trix')
      return true
    elsif (ext == 'trig')
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
    when :transform
      handle_transform_and_render
    when :create_transform
      handle_create_transform_and_render
    when :save_transform
      handle_save_transform_and_render
    when :transform_select_execute
      handle_transform_select_execute_and_render
    when :transform_select_preview
      handle_transform_select_preview_and_render
    when :transform_direct
      handle_transform_direct
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

  ##def handle_decide_and_render
  ##  puts "************ upwizard handle_decide_and_render"
  ##  ext = file_ext(@upwizard.original_filename)
  ##  if filestore_ext?(ext)
  ##    @upwizard.current_file_type = 'tabular'
  ##  elsif sparql_ext?(ext)
  ##    @upwizard.current_file_type = 'graph'
  ##  else
  ##    flash[:error] = 'Error: unsupported file extension' + ext.to_s
  ##    jump_to :decide
  ##  end
  ##  @upwizard.save
  ##  render_wizard
  ##end

  def fetch_file_select thing_id
    ret = {error_txt: nil, e: nil}
    begin
      @thing = Thing.find(thing_id)
      unless @thing.file == nil
        unless @upwizard.file == nil
          @upwizard.file.delete
        end
        @upwizard.file = @thing.file
        @upwizard.file_size = @thing.file_size
        # BEWARE: We presume that the file type of the thing has been correctly set by the model/controller!
        @upwizard.current_file_type = @thing.file_content_type
        @upwizard.original_filename = @thing.original_filename
      else
        ret[:error_txt] = "Selected filestore with no file attached"
      end
    rescue Exception => e
      ret[:error_txt] = 'Error fetching file with ID ' + thing_id.to_s
      ret[:e] = e
    end
    return ret
  end

  def handle_file_select_transform_and_render
    puts "************ upwizard handle_file_select_transform"
    if @upwizard.radio_thing_id
      # Copy file information from the selected thing
      res = fetch_file_select @upwizard.radio_thing_id
      if res[:error_txt] == nil
        # Update state and process the new state
        @upwizard.trace_back_step_skip
        puts "Test printout: "+@thing.inspect
        jump_to :transform
        render_wizard
      else
        jump_error_to_state_and_render(res[:error_txt], :publish, res[:e])
      end
    else
      jump_error_to_state_and_render("No file is selected for transformation", :publish)
    end
    @upwizard.save
  end

  def handle_transform_and_render
    puts "************ upwizard handle_transform"
    #Placeholder ... Nothing to do so far

    @upwizard.save
    render_wizard
  end

  # Create a new transformation for the file
  def handle_create_transform_and_render
    puts "************ upwizard handle_create_transform"

    unless quota_room_for_new_transformations_count?(current_user)
      redirect_to quotas_path
    else
      @upwizard.trace_back_step_skip
      @upwizard.save
      @grafterizerPath = Rails.configuration.grafterizer['publicPath']

      raise ActionController::RoutingError.new('Grafterizer tool connection failed.') if !@grafterizerPath

      # Make sure the wiz_id is an number, to prevent XSS
      @distributionId = "upwizards--" + (params[:wiz_id].to_i.to_s)

      @upwizard.save
      render_wizard
    end
  end

  def handle_save_transform_and_render
    puts "************ upwizard handle_save_transform"
    respond_to do |format|
      if @upwizard.save
        format.html { jump_to :transform }
        format.json { head :no_content }
      else
        format.html { jump_to :create_transform }
        format.json { render json: @upwizard.errors, status: :unprocessable_entity }
      end
    end
  end

  def handle_transform_select_execute_and_render
    puts "************ upwizard handle_transform_select_execute"
    unless params[:upwizard][:radio_thing_id] == nil

      if params[:commit] == 'Next: Preview result of transformation'
        radio_id = params[:upwizard][:radio_thing_id]
#        jump_to (:preview_transform, selected_id: radio_id, wiz_id: @upwizard.id)
        redirect_to wizard_path(:transform_select_preview, selected_id: radio_id, wiz_id: @upwizard.id)
#        render_wizard
        return
        #    elsif params[:commit] == 'Next: Transform and add details'
        #    else
      end

      # Copy file information from the selected thing
      begin
        transformation = Transformation.find(@upwizard.radio_thing_id)

        if (@upwizard.task == 'file')
          begin
            @upwizard.transformed_file = transformation.transform(@upwizard.file, 'pipe')
            @upwizard.current_file_type = 'tabular'
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
          rescue Exception => e
            puts 'Error transforming file ' + @upwizard.get_current_file.id.to_s + 'with transformation ' + transformation.id.to_s + '(pipe)'  if @upwizard.get_current_file && transformation
            jump_error_to_state_and_render("Error transforming file.", :transform, e)
          end
        elsif (@upwizard.task == 'sparql')
          begin
            @upwizard.transformed_file = transformation.transform(@upwizard.file, 'graft')

            @upwizard.current_file_type = 'graph'
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
          rescue Exception => e
            puts 'Error transforming file with ID ' + @upwizard.get_current_file.id.to_s + 'with transformation ' + transformation.id.to_s + '(graft)' if @upwizard.get_current_file && transformation
            jump_error_to_state_and_render("Error transforming file.", :transform, e)
          end
        else
          redirect_error_to_dashboard('This wizard does not support <'+@upwizard.task+'>')
        end
      rescue Exception => e
        puts 'Error retrieving transformation'
        if (@upwizard)
          puts 'Transformation ID: ' + @upwizard.radio_thing_id.to_s if @upwizard.radio_thing_id
        else
          puts 'Wizard does not exist!'
        end
        jump_error_to_state_and_render("Error retrieving transformation.", :transform, e)
      end
    else
      jump_error_to_state_and_render("Error transformation is not selected.", :transform)
    end
    @upwizard.save
  end

  def handle_transform_select_preview_and_render
    puts "************ upwizard handle_transform_select_preview_and_render"
    @grafterizerPath = Rails.configuration.grafterizer['publicPath']
    unless !params[:wiz_id] || !params[:selected_id]
      begin
        transformation = Transformation.find(params[:selected_id])
        @transformationId = transformation.slug
        @publisherId = current_user.username
        @distributionId = "upwizards--" + (params[:wiz_id].to_i.to_s)
        @path_back = wizard_path(:transform)

        render_wizard
      rescue Exception => e
        if (@upwizard)
          puts 'Transformation ID: ' + @upwizard.radio_thing_id.to_s if @upwizard.radio_thing_id
        else
          puts 'Wizard does not exist!'
        end
        jump_error_to_state_and_render("Error retrieving transformation", :transform, e)
      end
    else
      @upwizard.trace_back_step_skip
      jump_error_to_state_and_render("Please select a transformation to preview.", :transform, e)
    end
  end

  def handle_transform_direct
    puts "************ upwizard handle_transform_direct"
    if params[:filestore_id]
      # Copy file information from the selected filestore
      res = fetch_file_select params[:filestore_id]
      if res[:error_txt] == nil
        @upwizard.save
        do_transform_direct
      else
        jump_error_to_state_and_render(res[:error_txt], :publish, res[:e])
      end
    else
      unless @upwizard.file == nil
        # Use uploaded file
        do_transform_direct
      else
        jump_error_to_state_and_render("No file is selected for transformation", :publish)
      end
    end
  end

  def do_transform_direct
    transformation_id = params[:transformation_id]
    if transformation_id
      begin
        transformation = Transformation.find(transformation_id)

        if (@upwizard.task == 'file')
          begin
            @upwizard.transformed_file = transformation.transform(@upwizard.file, 'pipe')
            @upwizard.current_file_type = 'tabular'
            @upwizard.save
            respond_to do |format|
              format.html { redirect_error_to_dashboard('Error URL not supported for HTML.') }
              format.json { render :show_json, status: :ok }
            end
          rescue Exception => e
            puts 'Error transforming file ' + @upwizard.get_current_file.id.to_s + 'with transformation ' + transformation.id.to_s + '(pipe)'  if @upwizard.get_current_file && transformation
            jump_error_to_state_and_render("Error transforming file.", :transform, e)
          end
        elsif (@upwizard.task == 'sparql')
          begin
            @upwizard.transformed_file = transformation.transform(@upwizard.file, 'graft')
            @upwizard.current_file_type = 'graph'
            @upwizard.save
            respond_to do |format|
              format.html { redirect_error_to_dashboard('Error URL not supported for HTML.') }
              format.json { render :show_json, status: :ok }
            end
          rescue Exception => e
            puts 'Error transforming file with ID ' + @upwizard.get_current_file.id.to_s + 'with transformation ' + transformation.id.to_s + '(graft)' if @upwizard.get_current_file && transformation
            jump_error_to_state_and_render("Error transforming file.", :transform, e)
          end
        else
          redirect_error_to_dashboard('This wizard does not support <'+@upwizard.task+'>')
        end
      rescue Exception => e
        puts 'Error retrieving transformation'
        if (@upwizard)
          puts 'Transformation ID: ' + transformation_id.to_s if transformation_id
        else
          puts 'Wizard does not exist!'
        end
        jump_error_to_state_and_render("Error retrieving transformation.", :transform, e)
      end
    else
      jump_error_to_state_and_render("Error transformation is not selected.", :transform)
    end
  end

  # Pass the transformed tabular object over to a new filestore object
  def handle_fill_filestore_and_render
    puts "************ upwizard handle_fill_filestore"

    @upwizard.current_file_type = 'tabular'
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

    @upwizard.current_file_type = 'graph'
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
    # ?!?!?!?!
    #    @upwizard.current_file_type = 'tabular'  # Dont use the transformed file
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

    #    @upwizard.transformed_file_type = 'none'  # Dont use the transformed file
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

  ##def handle_go_back_and_render
  ##  puts "************ upwizard handle_go_back"
  ##  back_step = @upwizard.trace_pop_back_step
  ##
  ##  jump_to back_step unless back_step == nil
  ##  @upwizard.save
  ##  render_wizard
  ##end

  ##def handle_go_cancel_and_render
  ##  authorize! :destroy, @upwizard
  ##  @upwizard.destroy
  ##  redirect_to dashboard_path
  ##end

  ##def handle_not_implemented_and_render
  ##  puts "************ upwizard handle_not_implemented"
  ##  #Will show a debug page
  ##  #Nothing more to do so far...
  ##  @upwizard.trace_back_step_skip
  ##  @upwizard.save
  ##  render_wizard
  ##end

  def handle_error_and_render
    puts "************ upwizard handle_error"
    #Will show a debug page
    #Nothing more to do so far...
    @upwizard.trace_back_step_skip
    @upwizard.save
    render_wizard
  end

end
