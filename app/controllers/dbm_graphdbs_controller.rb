class DbmGraphdbsController < DbmsController
  include DbmGraphdbHelper
  
  before_action :set_dbm_graphdb, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  
  wrap_parameters :dbm_grapdb, include: [:dbm_account_username, :dbm_account_password, :name, :db_plan, :endpoint]

  ######
  public
  ######

  # GET /dbm_graphdbs
  def index
    @dbm_graphdbs = current_user.search_for_existing_dbms_type("DbmGrapdb")
  end


  # GET /dbm_graphdbs/new
  def new
    @dbm_graphdb = DbmGraphdb.new
  end


  # GET /dbm_graphdbs/1
  def show
    respond_to do |format|
        format.html { redirect_to dbms_path }
        format.json { render :show }
    end
  end


  # GET /dbm_graphdbs/1/edit
  def edit
  end


  # POST /dbm_graphdbs
  def create
    ok = false
    begin
      @dbm_graphdb = DbmGraphdb.new(dbm_graphdb_params)
      @dbm_graphdb.user = current_user
      @dbm_graphdb.endpoint = dbm_graphdb_params[:endpoint]

      # Create and add new account DBM
      account_name = dbm_graphdb_params[:dbm_account_username]
      account_password = dbm_graphdb_params[:dbm_account_password]
      @dbm_graphdb.add_account(account_name, account_password)

      ok = @dbm_graphdb.save
    rescue => e
      ok = false
      puts e.message
      puts e.backtrace.inspect
      flash[:error] = "Error registering GraphDB database: #{e.message}"
    end    

    respond_to do |format|
      if @dbm_graphdb.save
        format.html { redirect_to dbms_path, notice: 'Database was successfully registered.' }
        format.json { render :show, status: :created, location: @dbm_graphdb }
      else
        format.html { render :new }
        format.json { render json: @dbm_graphdb.errors, status: :unprocessable_entity }
      end
    end
  end


  # PATCH/PUT /dbm_graphdbs/1
  def update
    respond_to do |format|
      if @dbm_graphdb.update(dbm_graphdb_params)
        format.html { redirect_to dbms_path, notice: 'Database was successfully updated.' }
        format.json { render :show, status: :ok, location: @dbm_graphdb }
      else
        format.html { render :edit }
        format.json { render json: @dbm_graphdb.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /dbm_graphdbs/1
  def destroy
    ok = false
    begin
      things = @dbm_graphdb.find_things
      raise "The database has #{things.count} assets connected. Delete assets first." if things.count > 0

      @dbm_graphdb.destroy
      ok = true
    rescue => e
      puts e.message
      puts e.backtrace.inspect
      flash[:error] = e.message
    end
    respond_to do |format|
      if ok
        format.html { redirect_to dbms_url, notice: 'Database was successfully unregistered.' }
        format.json { head :no_content }
      else
        format.html { redirect_to dbm_graphdbs_url }
        format.json { head :no_content, status: 'Failed to delete the database' }
      end
    end
  end


  #######
  private
  #######

  # Use callbacks to share common setup or constraints between actions
  def set_dbm_graphdb
    @dbm_graphdb = DbmGraphdb.find(params[:id])
  end

  # Only allow white listed paramters
  def dbm_graphdb_params
    params.require(:dbm_graphdb).permit(:dbm_account_username, :dbm_account_password, :name, :db_plan, :endpoint)
  end

  
end
