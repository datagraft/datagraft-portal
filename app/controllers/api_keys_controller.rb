class ApiKeysController < ApplicationController
  wrap_parameters :api_key, include: [:key_pub, :key_secret, :name, :enabled]

  before_action :set_api_key, only: [:show, :edit, :update, :destroy]
  before_action :set_dbm, only: [:index, :new, :create, :show, :edit, :update, :destroy]
  load_and_authorize_resource

  wrap_parameters :api_key, include: [:name, :enabled]

  # GET /api_keys
  # GET /api_keys.json
  def index
    @api_keys = current_user.api_keys.where(dbm_id: params[:dbm_id])
    ##@api_keys = []
    ##all_keys = ApiKey.all
    ##all_keys.each do |key|
    ##  dbm = key.dbm
    ##  unless dbm == nil
    ##    @api_keys << key if key.dbm.user == current_user
    ##  end
    ##end
  end

  # GET /api_keys/new
  def new
    @api_key = ApiKey.new
    @api_key.enabled = true
    @api_key.dbm = @dbm
  end

  # GET /api_keys/1
  # GET /api_keys/1.json
  def show
    respond_to do |format|
        format.html { redirect_to dbm_api_keys_path(@dbm) }
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
    @api_key.dbm = @dbm

    respond_to do |format|
      if @api_key.save
        @api_key.add_in_dbm
        format.html { redirect_to dbm_api_keys_path(@dbm), notice: 'Api key was successfully created.' }
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
        @api_key.update_in_dbm
        format.html { redirect_to dbm_api_keys_path(@dbm), notice: 'Api key was successfully updated.' }
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
    @api_key.delete_in_dbm
    @api_key.destroy
    respond_to do |format|
      format.html { redirect_to dbm_api_keys_path(@dbm), notice: 'Api key was successfully destroyed.' }
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

    def set_dbm
      @dbm = Dbm.find(params[:dbm_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def api_key_params
      params.require(:api_key).permit(:key_pub, :key_secret, :name, :enabled)
    end
end
