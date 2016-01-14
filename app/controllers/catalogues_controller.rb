class CataloguesController < ApplicationController
  include CataloguesHelper

  before_action :set_catalogue, only: [:show, :edit, :update, :destroy, :star_catalogue, :unstar_catalogue, :versions]
  # GET /:username/catalogues
  def index
    # If the user lists own catalogues
    if user_signed_in? && current_user.username == params[:username]
      @catalogues = current_user.catalogues
      # If user browses other people's catalogues
    else
      user = User.find_by_username(params[:username]) or not_found
      @catalogues = user.catalogues.where(public: true)
    end
    @catalogues = @catalogues.paginate(:page => params[:page], :per_page => 30)

  end

  # GET /:username/catalogues/new
  def new
    authorize! :create, Catalogue
    @catalogue = Catalogue.new
    @catalogue.user = current_user
  end

  # POST /:username/catalogues/:id
  def create
    authorize! :create, Catalogue
    @catalogue = Catalogue.new(catalogue_params)
    @catalogue.user = current_user

    create_fill

    respond_to do |format|
      if @catalogue.save
        format.html { redirect_to catalogue_path(@catalogue), notice: create_notice }
        format.json { render :show, status: :created, location: catalogue_path(@catalogue) }
      else
        format.html { render :new }
        format.json { render json: @catalogue.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /:username/catalogues/:id
  def show
    authorize! :read, @catalogue
  end

  # GET /:username/catalogues/:id/edit
  def edit
    authorize! :update, @catalogue
  end

  # PATCH/PUT /:username/catalogues/:id
  def update
    authorize! :update, @catalogue

    respond_to do |format|
      if @catalogue.update(catalogue_params)
        format.html { redirect_to catalogue_path(@catalogue), notice: update_notice }
        format.json { render :show, status: :ok, location: catalogue_path(@catalogue) }
      else
        format.html { render :edit }
        format.json { render json: @catalogue.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # DELETE /:username/catalogues/:id
  def destroy
    authorize! :destroy, @catalogue
    @catalogue.destroy

    respond_to do |format|
      format.html { redirect_to catalogues_path, notice: destroy_notice }
      format.json { head :no_content }
    end
  end
  
  # POST /:username/catalogues/:id/star
  def star_catalogue
    authenticate_user!
    authorize! :read, @catalogue
    current_user.star_catalogue(@catalogue)
    respond_to do |format|
      format.html { redirect_to catalogue_path(@catalogue), notice: star_notice }
      format.json { head :no_content }
    end
  end
  
  def unstar_catalogue
    authenticate_user!
    authorize! :read, @catalogue
    current_user.unstar_catalogue(@catalogue)
    respond_to do |format|
      format.html { redirect_to catalogue_path(@catalogue), notice: unstar_notice }
      format.json { head :no_content }
    end
  end
  
  # GET /:username/:resource/:id/versions
  def versions
    authorize! :read, @catalogue
    @versions = @catalogue.versions.reverse
  end
  
  protected
  def create_notice
    'Catalogue has been successfully created!'
  end

  def update_notice
    'Catalogue has been successfully updated!'
  end

  def create_fill
    # deal with it
    @catalogue.name = Bazaar.object if @catalogue.name.blank?
  end
  
  def destroy_notice
    'Catalogue has been successfully destroyed!'
  end
  
  def star_notice
    'Successfully starred catalogue!'
  end
  
  def unstar_notice
    'Successfully un-starred catalogue!'
  end
  
  private
  def set_catalogue
    throw "A username parameter is required" if not params[:username]
    user = User.find_by_username(params[:username]) or not_found
    @catalogue = Catalogue.friendly.find(params[:id])
  end
  def catalogue_params
    params.require(:catalogue).permit([:public, :name])
  end

end