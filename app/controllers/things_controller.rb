class ThingsController < ApplicationController
  include ApplicationHelper
  include ThingHelper

  before_action :set_thing, only: [:show, :edit, :update, :destroy, :star, :unstar, :versions]

  # GET /:username/:resource
  def index
    # If the user lists her own resources
    if user_signed_in? && current_user.username == params[:username]
      @things = current_user.send(virtual_resources_name)
      # If she is just browsing other people's pages
    else
      user = User.find_by_username(params[:username]) or not_found
      @things = user.send(virtual_resources_name).where(public: true)
    end

    if params[:search]
      # TODO execute this automatically
      ActiveRecord::Base.connection.execute("SELECT set_limit(0.1);")
      @things = @things.fuzzy_search(params[:search])
    end

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

  # GET /:username/:resource/:id/versions
  def versions
    authorize! :read, @thing
    @versions = @thing.versions.reverse
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
    user = User.find_by_username(params[:username]) or not_found
    @thing = user.send(virtual_resources_name).friendly.find(params[:id])
    instance_variable_set("@"+virtual_resource_name(true), @thing)
  end
end