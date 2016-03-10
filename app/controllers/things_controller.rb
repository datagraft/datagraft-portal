class ThingsController < ApplicationController
  include ApplicationHelper
  include ThingHelper

  before_action :set_thing, only: [
    :show, :edit, :update, :destroy, :star, :unstar, :fork, :versions,
    :show_metadata, :edit_metadata, :delete_metadata,
    :show_configuration, :edit_configuration, :delete_configuration
  ]

  # GET /:username/:resource
  def index
    # If the user lists her own resources
    if user_signed_in? && (current_user.username == params[:username] || params[:username] == 'myassets')
      @user = current_user
      @things = @user.send(virtual_resources_name)
      # If she is just browsing other people's pages
    else
      raise CanCan::AccessDenied.new("Not authorized!") if params[:username] == 'myassets'
      # raise ActionController::RoutingError.new('Forbidden') if params[:username] == 'myassets'
      @user = User.find_by_username(params[:username]) or not_found
      @things = @user.send(virtual_resources_name).where(public: true)
    end

    if params[:search]
      # TODO execute this automatically
      # ActiveRecord::Base.connection.execute("SELECT set_limit(0.1);")
      # @things = @things.fuzzy_search(params[:search])
      @things = @things.basic_search({metadata: params[:search], name: params[:search]}, false)
    end

    @things = @things.includes(:user).order(stars_count: :desc, created_at: :desc)

    @things = @things.paginate(:page => params[:page], :per_page => 30)


    instance_variable_set("@"+virtual_resources_name, @things)
  end

  # GET /:username/:resource/:id
  def show
    authorize! :read, @thing
  end

  # GET /:username/:resource/:id/edit
  def edit
    authorize! :update, @thing
  end

  # GET /:username/:resource/new
  def new
    resource = virtual_resource
    authorize! :create, resource
    @thing = resource.new
    @thing.user = current_user
    instance_variable_set("@"+virtual_resource_name(true), @thing)
  end

  # POST /:username/:resource/:id
  def create
    resource = virtual_resource
    authorize! :create, resource
    @thing = resource.new(self.send(virtual_resource_name(true)+"_params"))
    @thing.user = current_user

    fill_name_if_empty

    instance_variable_set("@"+virtual_resource_name(true), @thing)

    respond_to do |format|
      if @thing.save
        format.html { redirect_to thing_path(@thing), notice: create_notice }
        format.json { render :show, status: :created, location: thing_path(@thing) }
      else
        format.html { render :new }
        format.json { render json: @thing.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /:username/:resource/:id
  def update
    authorize! :update, @thing

    instance_variable_set("@"+virtual_resource_name(true), @thing)

    respond_to do |format|
      if @thing.update(self.send(virtual_resource_name(true)+"_params"))
        format.html { redirect_to thing_path(@thing), notice: update_notice }
        format.json { render :show, status: :ok, location: thing_path(@thing) }
      else
        format.html { render :edit }
        format.json { render json: @thing.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /:username/:resource/:id
  def destroy
    authorize! :destroy, @thing
    @thing.destroy

    respond_to do |format|
      format.html { redirect_to things_path(@thing), notice: destroy_notice }
      format.json { head :no_content }
    end
  end

  # POST /:username/:resource/:id/star
  def star
    authenticate_user!
    authorize! :read, @thing
    current_user.star(@thing)
    respond_to do |format|
      format.html { redirect_to thing_path(@thing), notice: star_notice }
      format.json { head :no_content }
    end
  end

  # POST /:username/:resource/:id/unstar
  def unstar 
    authenticate_user!
    authorize! :read, @thing
    current_user.unstar(@thing)
    respond_to do |format|
      format.html { redirect_to thing_path(@thing), notice: unstar_notice }
      format.json { head :no_content }
    end
  end

  # POST /:username/:resource/:id/fork
  def fork
    authenticate_user!
    authorize! :read, @thing
    @thing = current_user.fork(@thing)
    respond_to do |format|
      format.html { redirect_to thing_path(@thing), notice: unstar_notice }
      format.json { head :no_content }
    end
  end


  # GET /:username/:resource/:id/versions
  def versions
    authorize! :read, @thing
    @versions = @thing.versions.reverse
  end

  # GET /:username/:resource/:id/metadata
  # GET /:username/:resource/:id/metadata/:key
  def show_metadata
    authorize! :read, @thing
    show_json @thing.metadata
  end

  # GET /:username/:resource/:id/configuration
  # GET /:username/:resource/:id/configuration/:key
  def show_configuration
    authorize! :read, @thing
    show_json @thing.configuration
  end

  # POST  /:username/:resource/:id/metadata
  # PUT   /:username/:resource/:id/metadata
  # POST  /:username/:resource/:id/metadata/:key
  # PATCH /:username/:resource/:id/metadata/:key
  # PUT   /:username/:resource/:id/metadata/:key
  def edit_metadata
    authorize! :create, @thing

    edit_json(@thing.metadata) do |new_data|
      @thing.metadata = new_data
      @thing.paper_trail_event = 'edit metadata'
    end
  end

  def edit_configuration
    authorize! :create, @thing

    edit_json(@thing.configuration) do |new_data|
      @thing.configuration = new_data
      @thing.paper_trail_event = 'edit configuration'
    end
  end

  # DELETE /:username/:resource/:id/metadata
  # DELETE /:username/:resource/:id/metadata/:key
  def delete_metadata
    authorize! :delete, @thing

    delete_json(@thing.metadata) do |new_data|
      @thing.metadata = new_data
      @thing.paper_trail_event = 'delete metadata'
    end
  end

  def delete_configuration
    authorize! :delete, @thing

    delete_json(@thing.configuration) do |new_data|
      @thing.configuration = new_data
      @thing.paper_trail_event = 'delete configuration'
    end
  end

  protected
  # These two methods are magic and it's probably faster to override them
  # in the child classes

  def virtual_resource_name(underscore = false)
    name = /^(.+)sController$/.match(self.class.name)[1]
    underscore ? name.underscore : name 
  end

  def virtual_resources_name
    /^(.+)_controller$/.match(self.class.name.underscore)[1]
  end

  def virtual_resource
    Object.const_get(virtual_resource_name)
  end

  def create_notice
    'Asset has been successfully created!'
  end

  def update_notice
    'Asset has been successfully updated!'
  end

  def destroy_notice
    'Asset has been successfully destroyed!'
  end

  def star_notice
    'Successfully starred asset!'
  end
  
  def unstar_notice
    'Successfully un-starred asset!'
  end

  def cannot_save_metadata_notice
    'Unable to save the metadata'
  end
  
  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def fill_name_if_empty
    # deal with it
    @thing.name = Bazaar.object if @thing.name.blank?
  end

  private
  def set_thing
    throw "A username parameter is required" if not params[:username]
    if user_signed_in? && (current_user.username == params[:username] || params[:username] == 'myassets')
      user = current_user
    else
      raise CanCan::AccessDenied.new("Not authorized!") if params[:username] == 'myassets'
      user = User.find_by_username(params[:username]) or not_found
    end
    @thing = user.send(virtual_resources_name).friendly.find(params[:id])

    if params[:version_at]
      @latest_thing = @thing
      @thing = @thing.version_at(params[:version_at]) or not_found
    end

    instance_variable_set("@"+virtual_resource_name(true), @thing)
  end

  def show_json(data)
    if params["key"]
      data = Rodash.get(data, params["key"])
      not_found if not data
    end

    render :json => data
  end

  def edit_json(full_data)

    # Use raw_post because it doesn't contain magic variables
    data = request.raw_post

    begin
      data = JSON.parse(data)    
    rescue JSON::ParserError => e
      # Automatically convert few json types
      if data == 'true'
        data = true
      elsif data == 'false'
        data = false
      elsif data =~ /\./
        data = Float(data) rescue data
      else
        data = Integer(data) rescue data
      end
    end

    if params[:key]
      Rodash.set(full_data, params[:key], data)
      yield full_data
    else
      yield data
    end

    if @thing.save
      head :created
    else
      render json: @thing.errors, status: :unprocessable_entity
    end
  end

  def delete_json(full_data)
    if params[:key]
      Rodash.unset(full_data, params[:key])
      yield full_data
    else
      yield nil
    end

    if @thing.save
      head :ok
    else
      render json: @thing.errors, status: :unprocessable_entity
    end
  end
end