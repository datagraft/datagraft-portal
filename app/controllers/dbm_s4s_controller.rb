class DbmS4sController < DbmsController
  include DbmS4Helper

  before_action :set_dbm_s4, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  wrap_parameters :dbm_s4, include: [:dbm_account_username, :dbm_account_password, :name, :db_plan, :endpoint, :key, :secret]

  ######
  public
  ######

  # GET /dbm_s4s
  def index
    @dbm_s4s = current_user.search_for_existing_dbms_type("DbmS4")
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

    # Create and add new API Key to DBM
    key_name = "Manually registered S4 API Key"
    key_pub = dbm_s4_params[:key]
    key_secret = dbm_s4_params[:secret]
    @dbm_s4.add_key(key_name, key_pub, key_secret)

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
    ok = false
    begin
      @dbm_s4.destroy
      ok = true
    rescue => e
      puts e.message
      puts e.backtrace.inspect
      flash[:error] = e.message
    end
    respond_to do |format|
      if ok
        format.html { redirect_to dbm_s4s_url, notice: 'DBM S4 was successfully destroyed.' }
        format.json { head :no_content }
      else
        format.html { redirect_to dbm_s4s_url }
        format.json { head :no_content, status: 'Failed to delete the database' }
      end
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
