class DbmS4sController < ApplicationController
  include DbmS4Helper

  before_action :set_dbm_s4, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  
  wrap_parameters :api_key, include: [:dbm_account_username, :dbm_account_password, :name, :db_plan, :endpoint, :key, :secret]

  ######
  public
  ######
  
  # GET /dbm_s4s
  def index
    @dbm_s4s = current_user.dbms
  end

  
  # GET /dbm_s4s/new
  def new
    @dbm_s4 = DbmS4.new
  end

  
  # GET /dbm_s4s/1
  def show
    respond_to do |format|
        format.html { redirect_to dbm_s4s_path }
        format.json { render :show }
    end
  end

  
  # GET /dbm_s4s/1/edit
  def edit
  end
  
  
  # POST /dbm_s4s
  def create
    @dbm_s4 = DbmS4.new(dbm_s4_params)
    @dbm_s4.user = current_user
    @dbm_s4.endpoint = dbm_s4_params[:endpoint]
    @dbm_s4.key = dbm_s4_params[:key]
    @dbm_s4.secret = dbm_s4_params[:secret]
    
    # Create and add new API Key to DBM
    api_key = ApiKey.new
    api_key.name = "Manually registered S4 API Key"
    api_key.key = dbm_s4_params[:key] + ':' + dbm_s4_params[:secret]
    api_key.enabled = true
    api_key.dbm = @dbm_s4
    api_key.user = current_user
    api_key.save
    @dbm_s4.api_keys
    
    respond_to do |format|
      if @dbm_s4.save
        format.html { redirect_to dbm_s4s_path, notice: 'DBM S4 was successfully created.' }
        format.json { render :show, status: :created, location: @dbm_s4 }
      else
        format.html { render :new }
        format.json { render json: @dbm_s4.errors, status: :unprocessable_entity }
      end
    end
  end
  
  
  # PATCH/PUT /dbm_s4s/1
  def update
    respond_to do |format|
      if @dbm_s4.update(dbm_s4_params)
        format.html { redirect_to dbm_s4s_path, notice: 'DBM S4 was successfully updated.' }
        format.json { render :show, status: :ok, location: @dbm_s4 }
      else
        format.html { render :edit }
        format.json { render json: @dbm_s4.errors, status: :unprocessable_entity }
      end
    end
  end

  
  # DELETE /dbm_s4s/1
  def destroy
    @dbm_s4.destroy
    respond_to do |format|
      format.html { redirect_to dbm_s4s_url, notice: 'DBM S4 was successfully destroyed.' }
      format.json { head :no_content }
    end
  end  


  #######
  private
  #######

  # Use callbacks to share common setup or constraints between actions
  def set_dbm_s4
    @dbm_s4 = DbmS4.find(params[:id])
  end
  
  
  # Only allow white listed paramters
  def dbm_s4_params
    #params.require(:dbm_s4).permit(:public, :name, :dbm_account_username, :dbm_account_password, :dbm_endpoint, :dbm_public, :dbm_api_key_key1, :dbm_api_key_secret1)
    params.require(:dbm_s4).permit(:dbm_account_username, :dbm_account_password, :name, :db_plan, :endpoint, :key, :secret)
  end
      
end
