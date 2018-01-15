class DbmArangosController < DbmsController

  before_action :set_dbm_arango, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  wrap_parameters :dbm_arango, include: [:dbm_account_username, :dbm_account_password, :name, :uri]

  ######
  public
  ######

  # GET /dbm_arangos
  def index
    @dbm_arangos = current_user.search_for_existing_dbms_type("DbmArango")
    find_dbms_rw
  end


  # GET /dbm_arangos/new
  def new
    @dbm_arangos = DbmArango.new
  end


  # GET /dbm_arangos/1
  def show
    respond_to do |format|
        format.html { redirect_to dbms_path }
        format.json { render :show }
    end
  end


  # GET /dbm_arangos/1/edit
  def edit
  end


  # POST /dbm_arangos
  def create
    ok = false
    begin
      @dbm_arango = DbmArango.new(dbm_arango_params)
      @dbm_arango.user = current_user
      @dbm_arango.uri = dbm_arango_params[:uri]

      # Create and add new account DBM

      account_name = dbm_arango_params[:dbm_account_username]
      account_password = dbm_arango_params[:dbm_account_password]
      @dbm_arango.add_account(account_name, account_password)

      ok = @dbm_arango.save
    rescue => e
      ok = false
      puts e.message
      puts e.backtrace.inspect
      flash[:error] = "Error registering server: #{e.message}"
    end

    respond_to do |format|
      if ok
        format.html { redirect_to dbms_path, notice: 'Server was successfully registered.' }
        format.json { render :show, status: :created, location: @dbm_arango }
      else
        format.html { render :new }
        format.json { render json: {error: flash[:error]}, status: :unprocessable_entity }
        @dbm_arango.destroy
      end

    end
  end


  # PATCH/PUT /dbm_arangos/1
  def update
    ok = false
    begin
      ok = @dbm_arango.assign_attributes(dbm_arango_params)
      @dbm_arango.test_server(false)
      ok = @dbm_arango.save
    rescue => e
      ok = false
      puts e.message
      puts e.backtrace.inspect
      flash[:error] = "Error updating server: #{e.message}"
    end

    respond_to do |format|
      if ok
        format.html { redirect_to dbms_path, notice: 'Server was successfully updated.' }
        format.json { render :show, status: :ok, location: @dbm_arango }
      else
        format.html { render :edit }
        format.json { render json: {error: flash[:error]}, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /dbm_arangos/1
  def destroy
    ok = false
    begin
      things = @dbm_arango.find_things
      raise "The server has #{things.count} assets connected. Delete assets first." if things.count > 0

      @dbm_arango.destroy
      ok = true
    rescue => e
      puts e.message
      puts e.backtrace.inspect
      flash[:error] = e.message
    end
    respond_to do |format|
      if ok
        format.html { redirect_to dbms_url, notice: 'Server was successfully unregistered.' }
        format.json { head :no_content }
      else
        format.html { redirect_to dbm_arangos_url }
        format.json { render json: {error: flash[:error]}, status:  :unprocessable_entity  }
      end
    end
  end


  #######
  private
  #######

  # Use callbacks to share common setup or constraints between actions
  def set_dbm_arango
    @dbm_arango = DbmArango.find(params[:id])
  end

  # Only allow white listed paramters
  def dbm_arango_params
    params.require(:dbm_arango).permit(:dbm_account_username, :dbm_account_password, :name, :uri)
  end

  def find_dbms_rw
    # Find valid dbms
    begin
      @dbm_entries = current_user.search_for_existing_dbms_reptype('ARANGO')
      @db_entries = []
      @dbm_entries.each do |dbm|
        db_arr = dbm.get_databases(false)
        db_arr.each do |db|
          if db[:access] == "rw"
            @db_entries << {description: "DBM: #{dbm.name}  =>  Database: #{db[:name]}", entry: "#{dbm.id} #{db[:name]}"}
          end
          puts "DBM: #{dbm.name} DB: #{db[:name]}"
        end
      end
    rescue => e
      flash[:error] = "Error searching for databases: #{e.message}"
      puts e.message
      # puts e.backtrace.inspect
    end
  end


end
