class ApiKeysController < ApplicationController

  before_action :set_api_key, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  wrap_parameters :api_key, include: [:name, :enabled]

  # GET /api_keys
  # GET /api_keys.json
  def index
    @api_keys = current_user.api_keys
  end

  # GET /api_keys/new
  def new
    @api_key = ApiKey.new
    @api_key.enabled = true
  end

  # GET /api_keys/1
  # GET /api_keys/1.json
  def show
    respond_to do |format|
        format.html { redirect_to api_keys_path }
        format.json { render :show }
    end
  end

  # GET /api_keys/1/edit
  def edit
  end

  # POST /api_keys
  # POST /api_keys.json
  def create
    @api_key = ApiKey.new(api_key_params)
    @api_key.name = Bazaar.object if @api_key.name.blank?
    @api_key.user = current_user
    @api_key.key = @api_key.new_ontotext_api_key(current_user)

    respond_to do |format|
      if @api_key.save
        format.html { redirect_to api_keys_path, notice: 'Api key was successfully created.' }
        format.json { render :show, status: :created, location: @api_key }
      else
        format.html { render :new }
        format.json { render json: @api_key.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /api_keys/1
  # PATCH/PUT /api_keys/1.json
  def update
    respond_to do |format|
      if @api_key.update(api_key_params)
        @api_key.update_in_ontotext(current_user)
        format.html { redirect_to api_keys_path, notice: 'Api key was successfully updated.' }
        format.json { render :show, status: :ok, location: @api_key }
      else
        format.html { render :edit }
        format.json { render json: @api_key.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /api_keys/1
  # DELETE /api_keys/1.json
  def destroy
    @api_key.delete_from_ontotext(current_user)
    @api_key.destroy
    respond_to do |format|
      format.html { redirect_to api_keys_url, notice: 'Api key was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # Return the first enabled API key
  def first
    key = ApiKey.first_or_create(current_user)
    render :text => key.key
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_api_key
      @api_key = ApiKey.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def api_key_params
      params.require(:api_key).permit(:name, :enabled)
    end
end
