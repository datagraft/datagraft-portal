class ThingsController < ApplicationController
  include ApplicationHelper
  include ThingHelper

  before_action :set_thing, only: [:show, :edit, :update, :destroy, :star, :unstar, :versions]

  # GET /:username/:resource
  def index
    # If the user lists her own resources
    if user_signed_in? && current_user.username == params[:username]
      @things = current_user.send(virtualResourcesName)
    # If she is just browsing other people's pages
    else
      user = User.find_by_username(params[:username]) or not_found
      @things = user.send(virtualResourcesName).where(public: true)
    end
  
    @things = @things.paginate(:page => params[:page], :per_page => 30)

    instance_variable_set("@"+virtualResourcesName, @things)
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
    resource = virtualResource
    authorize! :create, resource
    @thing = resource.new
    @thing.user = current_user
    instance_variable_set("@"+virtualResourceName(true), @thing)
  end

  # POST /:username/:resource/:id
  def create
    resource = virtualResource
    authorize! :create, resource
    @thing = resource.new(self.send(virtualResourceName(true)+"_params"))
    @thing.user = current_user

    create_fill

    instance_variable_set("@"+virtualResourceName(true), @thing)

    respond_to do |format|
      if @thing.save
        format.html { redirect_to thing_path(@thing), notice: createNotice }
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

    instance_variable_set("@"+virtualResourceName(true), @thing)

    respond_to do |format|
      if @thing.update(self.send(virtualResourceName(true)+"_params"))
        format.html { redirect_to thing_path(@thing), notice: updateNotice }
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
      format.html { redirect_to things_path(@thing), notice: destroyNotice }
      format.json { head :no_content }
    end
  end
 
  # POST /:username/:resource/:id/star
  def star
    authenticate_user!
    authorize! :read, @thing
    current_user.star(@thing)
    respond_to do |format|
      format.html { redirect_to thing_path(@thing), notice: 'Thank you so much <3' }
      format.json { head :no_content }
    end
  end

  # POST /:username/:resource/:id/unstar
  def unstar 
    authenticate_user!
    authorize! :read, @thing
    current_user.unstar(@thing)
    respond_to do |format|
      format.html { redirect_to thing_path(@thing), notice: 'No regrets' }
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

    def virtualResourceName(underscore = false)
      name = /^(.+)sController$/.match(self.class.name)[1]
      underscore ? name.underscore : name 
    end

    def virtualResourcesName
      /^(.+)_controller$/.match(self.class.name.underscore)[1]
    end

    def virtualResource
      Object.const_get(virtualResourceName)
    end

    def createNotice
      'Thing was successfully created'
    end

    def updateNotice
      'Thing was successfully updated'
    end

    def destroyNotice
      'Thing was successfully destroyed'
    end

    def not_found
      raise ActionController::RoutingError.new('Not Found')
    end
    
    def create_fill
      # deal with it
      @thing.name = Bazaar.object if @thing.name.blank?
    end

  private
    def set_thing
      throw "A username parameter is required" if not params[:username]
      user = User.find_by_username(params[:username]) or not_found
      @thing = user.send(virtualResourcesName).friendly.find(params[:id])
      instance_variable_set("@"+virtualResourceName(true), @thing)
    end
end