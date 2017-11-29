class ArangoDbsController < ThingsController
  include UpwizardHelper
  include QueriesHelper
  include QuotasHelper
  include DbmsHelper

  wrap_parameters :arango_db, include: [:public, :name, :description, :meta_keyword_list, :license, :publish_file, :db_entries]

  def new
    super
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

  def show
    super
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
          @coll_info_list << "#{coll[:name]}  Type: document  Count: #{info['count']}"
        else
          edges += info['count']
          @coll_info_list << "#{coll[:name]}  Type: edge  Count: #{info['count']}"
        end
      end
    rescue => e
      puts e.message
      puts e.backtrace.inspect
    end
    @db_edges = "Edges:#{edges}"
    @db_docs = "Documents:#{docs}"


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
      :meta_keyword_list, :publish_file, :db_entries,
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

end
