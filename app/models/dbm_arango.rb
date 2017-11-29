
class DbmArango < Dbm
  include HTTParty

  # Non-persistent attribute for storing inputs from new form
  attr_accessor :dbm_account_username
  attr_accessor :dbm_account_password

  ######
  public
  ######

  def get_supported_repository_types
    return %w(ARANGO)
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
    #db = get_database_obj(db_name)
    #coll = get_collection_obj(db, collection_name)
    #if type.downcase = 'edge'
    #  coll.create_edge_collection
    #else
    #  coll.create
    #end
    puts "***** Exit DbmArango.create_collection()"
  end

  # Fetch list of collections from a database
  def get_collections(database_name)
    puts "***** Enter DbmArango.get_collections(#{name})"
    coll_arr = adbm_collections(database_name)
    res_arr = []
    coll_arr.each do |coll|
      res_arr << {name: coll[:collection], type: coll[:type], collection: coll, database: {name: database_name}}
    end
    puts "***** Exit DbmArango.get_collections()"
    return res_arr
  end

  def get_collection_info(coll)
    puts "***** Enter DbmArango.get_collection_status(#{name})"
    info = adbm_collection_info(coll[:database][:name], coll[:name])
    puts "***** Exit DbmArango.get_collection_status()"
    return info
  end

  # Delete collection
  def delete_collection(db_name, collection_name)
    puts "***** Enter DbmArango.delete_collection(#{name})"
    puts "***** Exit DbmArango.delete_collection()"
  end

  # List all databases available for current user
  def get_databases
    db_arr = adbm_databases
    res_arr = []
    db_arr.each do |db|
      res_arr << {name: db[:database]}
    end
    return res_arr
  end

  # Get URI for specific database
  def get_database_uri(db_name)
    "http://#{@adbm_server}:#{@adbm_port}/_db/#{db_name}/_admin/aardvark/index.html#login"
  end

  # Query specific database
  def query_database(db_name, query_string)
    puts "***** Enter DbmArango.query_database(#{name})"
    response = adbm_database_query(db_name, query_string)

    # Collect all headers from the first entry
    headers = []
    if response["result"].count > 0
      response["result"][0].each do |k,v|
        headers << k
      end
    end

    # Reformat the values into result_list["header_name"]["value"]
    result_list = []
    response["result"].each do |in_entry|
      out_entry = {}
      in_entry.each do |k,v|
        out_entry[k] = {"value" => v}
      end
      result_list << out_entry
    end
    res = {:results => result_list, :headers => headers}

    puts "***** Exit DbmArango.query_database()"
    return res
  end





  private

  def adbm_init
    if @adbm_init.nil?
      puts "***** adbm_init(#{name})"
      da = first_enabled_account
      @adbm_server = uri
      @adbm_port = "8529"
      self.class.base_uri "http://#{@adbm_server}:#{@adbm_port}"

      @adbm_user = da.name
      @adbm_password = da.password
      self.class.basic_auth @adbm_user, @adbm_password
      @adbm_request = {:body => {}, :headers => {}, :query => {}}
      @adbm_init = true
    end
  end

  def adbm_databases
    adbm_init
    result = self.class.get("/_api/database/user", @adbm_request)
    raise "Error fetching databases" unless result.code.between?(200, 299)
    result = result.parsed_response
    return result["result"].map{|x| {obj: 'DB', database: x}}
  end

  def adbm_collections(database_name, excludeSystem: true)
    adbm_init
    query = { "excludeSystem": excludeSystem }.delete_if{|k,v| v.nil?}
    request = @adbm_request.merge({ :query => query })
    result = self.class.get("/_db/#{database_name}/_api/collection", request)
    raise "Error fetching collections" unless result.code.between?(200, 299)

    result = result.parsed_response
    result["result"].map{|x| {obj: 'COLL', db: database_name, collection: x["name"], type: x['type'] == 3 ? 'Edge' : 'Collection'}}
  end

  def adbm_collection_info(db_name, coll_name)
    adbm_init
    result = self.class.get("/_db/#{db_name}/_api/collection/#{coll_name}/count", @adbm_request)
    raise "Error fetching collection info" unless result.code.between?(200, 299)
    result = result.parsed_response
  end

  def adbm_database_query(db_name, query_string)
    adbm_init
    body = {
      "query" => query_string,
      "limit" => 4,
      "count" => nil,
      "batchSize" => nil,
      "ttl" => nil,
      "cache" => nil,
      "options" => nil,
      "bindVars" => nil
    }.delete_if{|k,v| v.nil?}
    request = @adbm_request.merge({ :body => body.to_json })
    result = self.class.post("/_db/#{db_name}/_api/cursor", request)
    raise "Error querying database" unless result.code.between?(200, 299)
    result = result.parsed_response
    @quantity = result["count"]
    @hasMore = result["hasMore"]
    @id = result["id"]
    return result
  end

end
