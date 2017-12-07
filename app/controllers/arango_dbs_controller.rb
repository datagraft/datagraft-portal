class ArangoDbsController < ThingsController
  include UpwizardHelper
  include QueriesHelper
  include QuotasHelper
  include DbmsHelper

  wrap_parameters :arango_db, include: [:public, :name, :description, :meta_keyword_list, :license, :publish_file, :db_entries, :coll_name, :coll_type]

  def new
    super
    find_valid_dbms
  end

  def show
    super
    find_collection_info
  end

  def edit
    super
    find_collection_info
  end




  # GET      /:username/arango_dbs/:id/collection/new
  def collection_new
    set_thing
    authorize! :create, @thing
    @collection_types = @thing.dbm.get_collection_types
  end

  # POST     /:username/arango_dbs/:id/collection
  def collection_create
    ok = false
    set_thing
    authorize! :create, @thing

    begin
      res = @thing.dbm.create_collection(@thing.db_name, arango_db_params[:coll_name], arango_db_params[:coll_type])
      ok = true
    rescue => e
      ok = false
      flash[:error] = "Error creating collection '#{arango_db_params[:coll_name]}' #{e.message}"
      puts e.message
      puts e.backtrace.inspect
    end
    flash[:notice] = "Collection '#{arango_db_params[:coll_name]}' created" if ok == true
    find_collection_info

    respond_to do |format|
      format.html { redirect_to thing_edit_path(@thing) }
      format.json { head :no_content }
    end
  end

  # DELETE   /:username/arango_dbs/:id/collection/:collection_name
  def collection_destroy
    ok = false
    set_thing
    authorize! :destroy, @thing

    begin
      coll_arr = @thing.dbm.get_collections(@thing.db_name)
      coll_arr.each do |coll|
        puts "  COL: #{coll[:name]} #{coll[:type]}"
        if coll[:name] == params[:collection_name]
          info = @thing.dbm.delete_collection(coll)
          ok = true
        end
      end
      flash[:error] = "Could not find collection '#{params[:collection_name]}'" if ok == false
    rescue => e
      ok = false
      flash[:error] = "Error deleting collection '#{params[:collection_name]}' <#{e.message}>"
      puts e.message
      puts e.backtrace.inspect
    end
    flash[:notice] = "Collection '#{params[:collection_name]}' deleted" if ok == true
    find_collection_info

    respond_to do |format|
      format.html { redirect_to thing_edit_path(@thing) }
      format.json { head :no_content }
    end
  end

  # POST     /:username/arango_dbs/:id/collection/:collection_name/publish
  def collection_publish
    set_thing
    authorize! :update, @thing
  end

  def upload
    authorize! :create, ArangoDb
  end

  def create
    authorize! :create, ArangoDb
    db_entries = params[:arango_db][:db_entries]
    dbm_id = db_entries.split(' ')[0]
    db_name = db_entries.split(' ')[1]
    dbm = Dbm.where(id: dbm_id).first

    begin
      ok = false
      raise 'Error bad DBM reference' if dbm == nil
      raise 'Error DBM with different user' unless dbm.user == current_user

      @thing = ArangoDb.new(arango_db_params)
      @thing.user = current_user
      @thing.dbm = dbm
      @thing.db_name = db_name
      ok = @thing.save   # It is important to save @thing before using it in another Thread

      if !ok
        flash[:error] = "Could not create Arango DB connection. Please try again."
      end

    rescue => e
      puts e.message
      puts e.backtrace.inspect
      flash[:error] = e.message
    end

    respond_to do |format|
      if ok
        format.html { redirect_to thing_path(@thing), notice: create_notice }
        format.json { render :show, status: :created, location: thing_path(@thing) }
      else
        format.html { redirect_to dashboard_path  }
        format.json { render json: @thing.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize! :update, @thing
    begin
      super
    rescue => e
      puts e.message
      puts e.backtrace.inspect
      flash[:error] = "Could not update Arango DB connection."
    end
  end

  def destroy
    authorize! :destroy, @thing

    ok = false
    begin
      super
      ok = true
    rescue => e
      puts e.message
      puts e.backtrace.inspect
      flash[:error] = e.message
    end
  end

  # Method called by the query execute form
  def execute_query
    set_thing
    authorize! :read, @thing

    @query = Query.new
    @query.name = 'Unsaved query'
    @query.query_string =
      if params[:existing_query] != nil
        params[:existing_query]
      else
        if params["query_string"] != nil
          params["query_string"]
        else
          params["execute_query"]["query_string"]
        end
      end
    @query.language = 'AQL'

    begin
      @query_error = ""
      @query_result = @query.execute_on_arango_db(@thing, current_user)
    rescue => e
      puts "Error querying ArangoDb"
      ## flash[:error] = e.message
      @query_result = {
        headers: [],
        results: []
        }
      @query_error = "Error querying ArangoDb #{e.message}"
    end

    if @query_result.blank?
      @results_list = []
      @query_error = "Blank result"
    else
      @results_list = @query_result[:results]
    end

    #render :partial => 'execute_query_results' if request.xhr?
    respond_to do |format|
      format.html { render :partial => 'execute_query_results' if request.xhr? }
      format.json { render 'execute_query_results' }
    end
  end

  private
  def arango_db_params
    params.require(:arango_db).permit(:public, :name, :description, :license,
      :meta_keyword_list, :publish_file, :db_entries, :coll_name, :coll_type,
      queries_attributes: [:id, :name, :query_string, :description, :language, :_destroy]) ## Rails 4 strong params usage
  end

  def arango_db_set_relations(ad)
    return if ad.queries.blank?
    ad.queries.each do |query|
      query.public = ad.public
      query.user = ad.user
    end
  end

  def arango_db_params_partial
    params.permit(:arango_db, :public, :name, :description, :license, :meta_keyword_list) ## Rails 4 strong params usage
  end

  def find_valid_dbms
    # Find valid dbms
    @dbm_entries = current_user.search_for_existing_dbms_reptype('ARANGO')
    @db_entries = []
    @dbm_entries.each do |dbm|
      db_arr = dbm.get_databases
      db_arr.each do |db|
        @db_entries << ["DBM: #{dbm.name}  =>  Database: #{db[:name]}", "#{dbm.id} #{db[:name]}"]
        puts "DBM: #{dbm.name} DB: #{db[:name]}"
      end
    end
  end

  def find_collection_info
    docs = 0
    edges = 0
    @coll_info_list = []
    begin
      @dbm_info = dbms_descriptive_name(@thing.dbm)
      coll_arr = @thing.dbm.get_collections(@thing.db_name)
      coll_arr.each do |coll|
        puts "  COL: #{coll[:name]} #{coll[:type]}"
        info = @thing.dbm.get_collection_info(coll)
        if info['type'] == 2
          docs += info['count']
          type = 'document'
        else
          edges += info['count']
          type = 'edge'
        end
        @coll_info_list << {name: coll[:name], type: type, count: info['count']}
      end
      @db_edges = "Edges:#{edges}"
      @db_docs = "Documents:#{docs}"
    rescue => e
      @db_edges = "Edges:#{edges}"
      @db_docs = "Documents:#{docs}"
      puts e.message
      puts e.backtrace.inspect
    end
  end


end
