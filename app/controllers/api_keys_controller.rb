class ApiKeysController < ApplicationController
  wrap_parameters :api_key, include: [:key_pub, :key_secret, :name, :enabled]

  before_action :set_api_key, only: [:show, :edit, :update, :destroy]
  before_action :set_dbm, only: [:index, :new, :create, :show, :edit, :update, :destroy]
  load_and_authorize_resource

  # GET /api_keys
  # GET /api_keys.json
  def index_all
    @api_keys = []
    all_keys = current_user.api_keys.all
    all_keys.each do |key|
      dbm = key.dbm
      unless dbm == nil
        @api_keys << key
      end
    end
  end

  # GET /dbms/dbm_id/api_keys
  # GET /dbms/dbm_id/api_keys.json
  def index
    @api_keys = current_user.api_keys.where(dbm_id: params[:dbm_id])
  end

  # GET /dbms/dbm_id/api_keys/new
  def new
    @api_key = ApiKey.new
    @api_key.enabled = true
    @api_key.dbm = @dbm
  end

  # GET /dbms/dbm_id/api_keys/1
  # GET /dbms/dbm_id/api_keys/1.json
  def show
    respond_to do |format|
        format.html { redirect_to dbm_api_keys_path(@dbm) }
        format.json { render :show }
    end
  end

  # GET /dbms/dbm_id/api_keys/1/edit
  def edit
  end

  # POST /dbms/dbm_id/api_keys
  # POST /dbms/dbm_id/api_keys.json
  def create
    @api_key = ApiKey.new(api_key_params)
    @api_key.name = Bazaar.object if @api_key.name.blank?
    @api_key.user = current_user
    @api_key.dbm = @dbm

    respond_to do |format|
      if @dbm.allow_manual_api_key?
        if @api_key.save
          @api_key.add_in_dbm
          format.html { redirect_to dbm_api_keys_path(@dbm), notice: 'API key was successfully created.' }
          format.json { render :show, status: :created, location: dbm_api_key_path(@dbm, @api_key) }
        else
          format.html { render :new }
          format.json { render json: @api_key.errors, status: :unprocessable_entity }
        end
      else
        format.html { redirect_to dbm_api_keys_path(@dbm), error: 'Manual API key not supported by this DBM.' }
        # json error code to be discussed. :upgrade_required, :insufficient_storage
        format.json { render json: { error: 'Manual API key not supported by this DBM.'}, status: :unprocessable_entity}
      end
    end
  end

  # PATCH/PUT /dbms/dbm_id/api_keys/1
  # PATCH/PUT /dbms/dbm_id/api_keys/1.json
  def update
    ok = true
    if @dbm.allow_manual_api_key?
      filtered_params = api_key_params
    else
      filtered_params = api_key_params_no_manual_key
    end

    begin
      ok = @api_key.update(filtered_params)
      @api_key.update_in_dbm if ok
    rescue => e
      ok = false
    end

    respond_to do |format|
      if ok
        format.html { redirect_to dbm_api_keys_path(@dbm), notice: 'API key was successfully updated.' }
        format.json { render :show, status: :ok, location: dbm_api_key_path(@dbm, @api_key) }
      else
        format.html { render :edit }
        format.json { render json: @api_key.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dbms/dbm_id/api_keys/1
  # DELETE /dbms/dbm_id/api_keys/1.json
  def destroy
    ok = true
    begin
      @api_key.delete_in_dbm
      @api_key.destroy
    rescue => e
      ok = false
    end

    respond_to do |format|
      if ok
        format.html { redirect_to dbm_api_keys_path(@dbm), notice: 'API key was successfully destroyed.' }
        format.json { head :no_content }
      else
        format.html { redirect_to dbm_api_keys_path(@dbm), error: 'Failed to delete API key.' }
        format.json { head :no_content, status: :unprocessable_entity }
      end
    end
  end

  # Return the first enabled API key
  #def first
  #  key = ApiKey.first_or_create(current_user)
  #  render :text => key.key
  #end

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
    def api_key_params_no_manual_key
      params.require(:api_key).permit(:name, :enabled)
    end
end
