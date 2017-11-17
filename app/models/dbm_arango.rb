require "arangorb"

class DbmArango < Dbm

  # Non-persistent attribute for storing inputs from new form
  attr_accessor :dbm_account_username
  attr_accessor :dbm_account_password

  ######
  public
  ######

  @@supported_repository_types = %w(ARANGO)
  def get_supported_repository_types
    return @@supported_repository_types
  end

  def uri
    configuration["uri"] if configuration
  end

  def uri=(val)
    touch_configuration!
    configuration["uri"] = val
  end

  def find_things
    adb = []
    self.things.each do |thing|
      adb << thing
    end
    return adb
  end

  # Create a collection in a database
  def create_collection(db_name, collection_name, type)
    puts "***** Enter DbmArango.create_collection(#{name})"
    db = get_database_obj(db_name)
    coll = get_collection_obj(db, collection_name)
    if type.downcase = 'edge'
      coll.create_edge_collection
    else
      coll.create
    end
    puts "***** Exit DbmArango.create_collection()"
  end

  # Fetch list of collections from a database
  def get_collections(db_name)
    puts "***** Enter DbmArango.get_collections(#{name})"
    db = get_database_obj(db_name)
    coll_arr = get_collections_obj(db)
    res_arr = []
    coll_arr.each do |coll|
      res_arr << {name: coll.collection, type: coll.type, collection: coll}
    end
    puts "***** Exit DbmArango.get_collections()"
    return res_arr
  end

  def get_collection_status(db_name, collection_name)
    puts "***** Enter DbmArango.get_collection_status(#{name})"
    status = {}
    db = get_database_obj(db_name)
    coll = get_collection_obj(db, collection_name)
    puts "***** Exit DbmArango.get_collection_status()"
    return status
  end

  # Delete collection
  def delete_collection(db_name, collection_name)
    puts "***** Enter DbmArango.delete_collection(#{name})"
    puts "***** Exit DbmArango.delete_collection()"
  end

  def get_databases
    arango_init
    db_arr = ArangoServer.databases
    res_arr = []
    db_arr.each do |db|
      res_arr << {name: db.database, db: db}
    end
    return res_arr
  end


  private

  def arango_init
    if @arango_init.nil?
      da = first_enabled_account
      @arango_init = true
      ArangoServer.default_server user: da.name, password: da.password, server: uri, port: "8529"
    end
  end

  def get_database_obj(db_name)
    arango_init
    db = ArangoDatabase.new database: db_name
    return db
  end

  def get_collections_obj(db)
    coll_arr = db.collections
    return coll_arr
  end

  def get_collection_obj(db, collection_name)
    coll = db.collection(collection_name).retrieve
    return coll
  end

  def get_graphs_obj(db)
    graph_arr = db.graphs
    return graph_arr
  end

  def get_graph_obj(db, graph_name)
    graph = db.graph(graph_name).retrieve
    return graph
  end


end
