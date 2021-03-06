class ThingsController < ApplicationController
  include ApplicationHelper
  include ThingHelper
  include ThingConcern
  # TODO remove this whenever possible
  include JsonConcern

  before_action :set_thing, only: [
    :show, :edit, :update, :destroy, :star, :unstar, :fork, :versions,
    :show_metadata, :edit_metadata, :delete_metadata,
    :show_configuration, :edit_configuration, :delete_configuration, :update_partial
    ]

  # TODO - should this be done for all actions?
  before_action :set_user, only: [:create]

  # GET /:username/:resource
  def index
    # If the user lists her own resources
    if user_signed_in? && (current_user.username == params[:username] || params[:username] == 'myassets')
      @user = current_user
      @things = @user.send(virtual_resources_name)
      # If she is just browsing other people's pages
    else
      raise CanCan::AccessDenied.new("Not authorized!") if params[:username] == 'myassets'
      if params[:username] == 'public_assets'
        @user = nil
        @things = Object.const_get(virtual_resource_name).where(public: true)
      else
        @user = User.find_by_username(params[:username]) or not_found
        @things = @user.send(virtual_resources_name).where(public: true)
      end
      # raise ActionController::RoutingError.new('Forbidden') if params[:username] == 'myassets'
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
    @is_owned = current_user === @thing.user
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

  # POST /:username/:resource/
  def create
    resource = virtual_resource
    authorize! :create, resource
    method_prefix = virtual_resource_name(true)

    @thing = resource.new(self.send("#{method_prefix}_params"))
    @thing.user = current_user

    set_relation = "#{method_prefix}_set_relations".to_sym
    if self.respond_to?(set_relation, :include_private)
      self.send(set_relation, @thing)
    end

    fill_default_values_if_empty

    instance_variable_set("@"+virtual_resource_name(true), @thing)

    respond_to do |format|
      if @thing.save
        format.html { redirect_to thing_path(@thing), notice: create_notice }
        format.json { render :show, status: :created, location: thing_path(@thing) }
      else
        ##format.html { edirect_to action: :new }
        format.html { render :new }
        format.json { render json: @thing.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /:username/:resource/:id
  def update
    authorize! :update, @thing
    method_prefix = virtual_resource_name(true)
    instance_variable_set("@"+method_prefix, @thing)

    @thing.assign_attributes(self.send(virtual_resource_name(true)+"_params"))

    set_relation = "#{method_prefix}_set_relations".to_sym
    if self.respond_to?(set_relation, :include_private)
      self.send(set_relation, @thing)
    end

    respond_to do |format|
      if @thing.save
        format.html { redirect_to thing_path(@thing), notice: update_notice }
        format.json { render :show, status: :ok, location: thing_path(@thing) }
      else
        format.html { render :edit }
        format.json { render json: @thing.errors, status: :unprocessable_entity }
      end
    end
  end

# PATCH /:username/:resource/:id
  def update_partial
    authorize! :update, @thing

    method_prefix = virtual_resource_name(true)
    instance_variable_set("@"+method_prefix, @thing)

    @thing.update_attributes(self.send(virtual_resource_name(true)+"_params_partial"))

    set_relation = "#{method_prefix}_set_relations".to_sym
    if self.respond_to?(set_relation, :include_private)
      self.send(set_relation, @thing)
    end

    respond_to do |format|
      if @thing.save
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
      format.html { redirect_to dashboard_path, notice: destroy_notice }
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
    @thing = @thing.fork(current_user)

    respond_to do |format|
      if @thing.save
        format.html { redirect_to thing_path(@thing), notice: copy_notice }
        format.json { render :show, status: :ok, location: thing_path(@thing) }
      else
        format.html { render :edit }
        format.json { render json: @thing.errors, status: :unprocessable_entity }
      end
    end
  end


  # GET /:username/:resource/:id/versions
  def versions
    authorize! :read, @thing
    @versions = @thing.versions.reverse
  end

  #def show_metadata
  #  authorize! :read, @thing
  #  show_json @thing.metadata
  #end

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

  def create_notice
    'Asset has been successfully created!'
  end

  def create_background_notice
    'Asset is created in background!'
  end

  def copy_notice
    'Successfully copied asset!'
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


  def fill_default_values_if_empty
    fill_name_if_empty
  end

  def fill_name_if_empty
    # deal with it
    @thing.name = Bazaar.object if @thing.name.blank?
  end

end
