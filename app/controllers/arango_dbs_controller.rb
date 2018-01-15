class ArangoDbsController < ThingsController
  include UpwizardHelper
  include QueriesHelper
  include QuotasHelper
  include DbmsHelper

  wrap_parameters :arango_db, include: [:public, :name, :description, :meta_keyword_list, :license, :publish_file, :db_entries, :coll_name, :coll_type, :from_to_coll_prefix, :json_option, :overwrite_option, :on_duplicate_option, :complete_option]

  def new
    super
    find_dbms_rw
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
    @collection_types = @thing.dbm.get_select_collection_types
  end

  # POST     /:username/arango_dbs/:id/collection
  def collection_create
    ok = false
    set_thing
    authorize! :create, @thing
    @collection_types = @thing.dbm.get_select_collection_types

    coll_type = @thing.dbm.eval_import_option(arango_db_params[:coll_type], @collection_types)

    begin
      raise "Invalid collection type: #{arango_db_params[:coll_type]}" if coll_type.nil?
      res = @thing.dbm.create_collection(@thing.db_name, arango_db_params[:coll_name], coll_type, public_access)
      ok = true
    rescue => e
      ok = false
      flash[:error] = "Error creating collection '#{arango_db_params[:coll_name]}' #{e.message}"
      puts e.message
      puts e.backtrace.inspect
    end
    flash[:notice] = "Collection '#{arango_db_params[:coll_name]}' created" if ok == true

    respond_to do |format|
      if ok
        format.html { redirect_to thing_edit_path(@thing) }
        format.json { head :no_content}
      else
        format.html { render :collection_new }
        format.json { render json: {error: flash[:error]}, status: :unprocessable_entity }
      end
    end

  end

  # DELETE   /:username/arango_dbs/:id/collection/:collection_name
  def collection_destroy
    ok = false
    set_thing
    authorize! :destroy, @thing

    begin
      coll_arr = @thing.dbm.get_collections(@thing.db_name, public_access)
      coll_arr.each do |coll|
        #puts "  COL: #{coll[:name]} #{coll[:type]}"
        if coll[:name] == params[:collection_name]
          info = @thing.dbm.delete_collection(coll, public_access)
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

    respond_to do |format|
      format.html { redirect_to thing_edit_path(@thing) }
      format.json { head :no_content }
    end
  end

  # GET     /:username/arango_dbs/:id/collection/:collection_name/collection_publish_new
  def collection_publish_new
    set_thing
    authorize! :update, @thing

    find_doc_collections(params[:collection_name])
    find_upload_options

  end

  # POST     /:username/arango_dbs/:id/collection/:collection_name/collection_publish
  def collection_publish
    ok = false
    @upload_result = {}
    set_thing
    authorize! :update, @thing
    find_doc_collections(params[:collection_name])
    find_upload_options

    json_option = @thing.dbm.eval_import_option(arango_db_params["json_option"], @json_options)
    overwrite_option = @thing.dbm.eval_import_option(arango_db_params["overwrite_option"], @overwrite_options)
    on_duplicate_option = @thing.dbm.eval_import_option(arango_db_params["on_duplicate_option"], @on_duplicate_options)
    complete_option = @thing.dbm.eval_import_option(arango_db_params["complete_option"], @complete_options)

    begin
      file = arango_db_params["publish_file"]
      raise "No file selected" if file.nil?

      info = @thing.dbm.get_collection_info(db_name: @thing.db_name, collection_name: params[:collection_name], public: public_access)

      if info['type'] == 'document'
        type = 'document'
        result = @thing.dbm.upload_document_data(file, @thing.db_name, params[:collection_name], public_access, json_option, overwrite_option, on_duplicate_option, complete_option)
        @upload_result[:result] = result
        puts "Publish result:#{result}"
        #if result["error"] != false
        #  flash[:error] = "Error publishing to collection '#{params[:collection_name]}'<br> #{result}"
        #elsif ((result["updated"] != 0) or (result["ignored"] != 0))
        #  flash[:warning] = "File published to collection '#{params[:collection_name]}'<br> #{result}"
        #else
        #  flash[:notice] = "File published to collection '#{params[:collection_name]}'<br> #{result}"
        #end
        ok = true
      else
        type = 'edge'
        from_to_coll_prefix = arango_db_params["from_to_coll_prefix"]
        raise "No document collection selected" if from_to_coll_prefix.nil?
        raise "No document collection selected" if from_to_coll_prefix == ""

        result = @thing.dbm.upload_edge_data(file, @thing.db_name, params[:collection_name], from_to_coll_prefix, from_to_coll_prefix, public_access, json_option, overwrite_option, on_duplicate_option, complete_option)
        @upload_result[:result] = result
        puts "Publish result:#{result}"
        #if result["error"] != false
        #  flash[:error] = "Error publishing to collection '#{params[:collection_name]}'<br> #{result}"
        #elsif ((result["updated"] != 0) or (result["ignored"] != 0))
        #  flash[:warning] = "File published to collection '#{params[:collection_name]}'<br> #{result}"
        #else
        #  flash[:notice] = "File published to collection '#{params[:collection_name]}'<br> #{result}"
        #end
        ok = true

      end
    rescue => e
      ok = false
      @upload_result[:error] = "#{e.message}"
      flash[:error] = "Error publishing file to '#{params[:collection_name]}' #{e.message}"
      puts e.message
      puts e.backtrace.inspect
    end

    respond_to do |format|
      if ok
        format.html { render :collection_publish }
        format.json { render json: @upload_result}
      else
        format.html { render :collection_publish_new }
        format.json { render json: {error: flash[:error]}, status: :unprocessable_entity }
      end
    end

  end

  def create
    ok = false
    authorize! :create, ArangoDb
    db_entries = params[:arango_db][:db_entries]
    find_dbms_rw

    begin
      @thing = ArangoDb.new(arango_db_params)
      @thing.user = current_user

      begin
        dbm_id = db_entries.split(' ')[0]
        db_name = db_entries.split(' ')[1]
        dbm = Dbm.where(id: dbm_id).first
      rescue => e
        raise "Invalid or missing db_entry"
      end
      find_dbms_rw

      raise 'Error bad DBM reference' if dbm == nil
      raise 'Error DBM with different user' unless dbm.user == current_user

      @thing.dbm = dbm
      @thing.db_name = db_name
      ok = @thing.save   # It is important to save @thing before using it in another Thread

      if !ok
        flash[:error] = "Could not create ArangoDB asset. Please try again."
      end

    rescue => e
      puts e.message
      puts e.backtrace.inspect
      flash[:error] = "Error creating ArangoDB asset: #{e.message}"
    end

    respond_to do |format|
      if ok
        format.html { redirect_to thing_path(@thing), notice: create_notice }
        format.json { render :show, status: :created, location: thing_path(@thing) }
      else
        format.html { render :new  }
        format.json { render json: {error: flash[:error]}, status: :unprocessable_entity }
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
      flash[:error] = "Could not update ArangoDB asset: #{e.message}"
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
      flash[:error] = "Could not delete ArangoDB asset: #{e.message}"
    end
  end

  # Method called by the query execute form
  def execute_query
    set_thing
    authorize! :read, @thing

    begin
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

      @query_error = ""
      @query_result = @query.execute_on_arango_db(@thing, current_user)
    rescue => e
      puts "Error querying ArangoDb #{e.message}"
      ## flash[:error] = e.message
      @query_result = {
        headers: [],
        results: []
        }
      @query_error = "Error querying ArangoDb: #{e.message}"
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
      :meta_keyword_list, :publish_file, :db_entries, :coll_name, :coll_type, :from_to_coll_prefix, :json_option, :overwrite_option, :on_duplicate_option, :complete_option,
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

  def public_access
    return @thing.user.username != current_user.username
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
            @db_entries << ["DBM: #{dbm.name}  =>  Database: #{db[:name]}", "#{dbm.id} #{db[:name]}"]
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

  def find_collection_info
    docs = 0
    edges = 0
    @coll_info_list = []
    @coll_info_rw_list = []
    begin
      @dbm_info = dbms_descriptive_name(@thing.dbm)
      @dbm_access = @thing.dbm.get_database_access(@thing.db_name, public_access)

      coll_arr = @thing.dbm.get_collections(@thing.db_name, public_access)
      coll_arr.each do |coll|
        puts "  COL: #{coll[:name]} #{coll[:type]}"
        info = @thing.dbm.get_collection_info(coll: coll, public: public_access)
        if info['type'] == 'document'
          docs += info['count']
          type = 'document'
        else
          edges += info['count']
          type = 'edge'
        end
        entry = {name: coll[:name], type: type, count: info['count'], access: coll[:access]}
        @coll_info_list << entry
        @coll_info_rw_list << entry if coll[:access] == 'rw'
      end
      @db_edges = "Edges:#{edges}"
      @db_docs = "Documents:#{docs}"
    rescue => e
      @db_edges = "Edges:#{edges}"
      @db_docs = "Documents:#{docs}"
      puts e.message
      #puts e.backtrace.inspect
      #flash[:error] = "Error searching for collections: #{e.message}"
    end
  end

  def find_doc_collections(doc_name)
    @doc_collections = []
    @doc_edge = true
    begin
      coll_arr = @thing.dbm.get_collections(@thing.db_name, public_access)
      coll_arr.each do |coll|
        info = @thing.dbm.get_collection_info(coll: coll, public: public_access)
        if info['type'] == 'document'
          @doc_collections << [coll[:name], coll[:name]]
          @doc_edge = false if doc_name == coll[:name]
        end
      end
    rescue => e
      puts e.message
      puts e.backtrace.inspect
      flash[:error] = "Error searching for collections: #{e.message}"
    end
  end

  def find_upload_options
    @json_options = @thing.dbm.get_select_import_json_options
    @overwrite_options = @thing.dbm.get_select_import_overwrite_options
    @on_duplicate_options = @thing.dbm.get_select_import_on_duplicate_options
    @complete_options = @thing.dbm.get_select_import_complete_options
  end

end
