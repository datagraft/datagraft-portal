
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

  def get_collection_types
    res = []
    res << ["Document", "2"]
    res << ["Edge", "3"]

    return res
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
  def create_collection(db_name, collection_name, type, public)
    puts "***** Enter DbmArango.create_collection(#{name})"
    adbm_init(public)
    res = adbm_collection_create(db_name, collection_name, type)
    puts "***** Exit DbmArango.create_collection()"
    return res
  end

  # Fetch list of collections from a database
  def get_collections(database_name, public)
    puts "***** Enter DbmArango.get_collections(#{name})"
    adbm_init(public)
    coll_arr = adbm_collections(database_name: database_name)
    res_arr = []
    coll_arr.each do |coll|
      access = adbm_collection_access(database_name, coll[:collection])
      res_arr << {name: coll[:collection], type: coll[:type], collection: coll, database: {name: database_name}, access: access}
    end
    puts "***** Exit DbmArango.get_collections()"
    return res_arr
  end

  def get_collection_info(coll: nil, db_name: nil, collection_name: nil, public: true)
    puts "***** Enter DbmArango.get_collection_info(#{name})"
    db_name = coll[:database][:name] unless coll.nil?
    collection_name = coll[:name] unless coll.nil?

    adbm_init(public)
    info = adbm_collection_info(db_name, collection_name)
    puts "***** Exit DbmArango.get_collection_info()"
    return info
  end

  # Delete collection
  def delete_collection(coll, public)
    puts "***** Enter DbmArango.delete_collection(#{name})"
    adbm_init(public)
    info = adbm_collection_delete(coll[:database][:name], coll[:name])
    puts "***** Exit DbmArango.delete_collection()"
    return info
  end

  def upload_document_data_array(jsonFile, db_name, coll_name, public)
    puts "***** Enter DbmArango.upload_document_data_array(#{name})"
    body = jsonFile.read
    waitForSync = nil
    onDuplicate = "replace"
    complete = "yes"

    adbm_init(public)
    res = adbm_document_importJSON(db_name, coll_name, body, waitForSync: waitForSync, onDuplicate: onDuplicate, complete: complete)
    puts "***** Exit DbmArango.upload_document_data_array(#{name})"
    return res
  end

  def upload_edge_data_array(jsonFile, db_name, coll_name, from_coll_name, to_coll_name, public)
    puts "***** Enter DbmArango.upload_edge_data_array(#{name})"
    body = jsonFile.read
    waitForSync = nil
    onDuplicate = "replace"
    complete = "yes"

    adbm_init(public)
    res = adbm_document_importJSON(db_name, coll_name, body, waitForSync: waitForSync, onDuplicate: onDuplicate, complete: complete, from: from_coll_name, to: to_coll_name)
    puts "***** Exit DbmArango.upload_edge_data_array(#{name})"
    return res
  end

  # List all databases available for current user
  def get_databases(public)
    adbm_init(public)
    db_arr = adbm_databases
    res_arr = []
    db_arr.each do |db|
      res_arr << {name: db[:name], access: db[:access]}
      puts "get_databases() user:#{@adbm_user} database:#{db[:name]} of type:#{db[:access]}"

    end
    return res_arr
  end

  def get_database_access(database_name, public)
    adbm_init(public)
    return adbm_database_access(database_name)
  end

  # Get URI for specific database
  def get_database_uri(db_name)
    "#{uri.rstrip}/_db/#{db_name}"
  end

  # Query specific database
  def query_database(db_name, query_string, public)
    puts "***** Enter DbmArango.query_database(#{name})"
    adbm_init(public)
    response = adbm_database_query(db_name, query_string)

    puts "***** Exit DbmArango.query_database()"
    return response
  end

  def test_user(user, password)
    puts "***** Enter DbmArango.test_user(#{name})"
    adbm_test_user(user, password)

    puts "***** Exit DbmArango.test_user()"
    return true
  end

  def test_server()
    puts "***** Enter DbmArango.test_server(#{name})"
    adbm_init(true)

    puts "***** Exit DbmArango.test_server()"
    return true
  end

  private
  def adbm_clear
    @adbm_init = nil
    @adbm_login = nil
    @adbm_databases = nil
    @adbm_database_access = nil
    @adbm_collection_access = nil
    @adbm_collections = nil
  end

  def adbm_init(public)
    if @adbm_init.nil?
      da = first_enabled_account(public)
      @acc_user = da.name
      @acc_password = da.password

      @adbm_init = true
    end
    adbm_login(@acc_user, @acc_password)
  end

  def adbm_test_user(user, password)
    adbm_login(user, password)
    adbm_clear
  end

  def adbm_login(user, password)
    if @adbm_login.nil?
      puts "***** Enter adbm_init_user(#{name})"
      @adbm_user = user
      @adbm_password = password
      @adbm_uri = uri.rstrip
      self.class.base_uri "#{@adbm_uri}"

      self.class.basic_auth @adbm_user, @adbm_password
      @adbm_request = {:body => {}, :headers => {}, :query => {}}
      @adbm_login = true

      # Check if access privileges are ok
      result = self.class.get("/_api/user/#{@adbm_user}", @adbm_request)
      respons = result.parsed_response
      #puts result.inspect

      raise "Error user:#{@adbm_user} is unauthorized" if result.code == 401
      raise "Error user:#{@adbm_user} has No access to server" if result.code == 403
      raise "Error user:#{@adbm_user} does not exist at server" if result.code == 404
      raise "Error user:#{@adbm_user} is not activated at server" if respons["active"] != true
      puts "***** Exit adbm_init_user(#{name})"
    end
  end

  def adbm_databases
    if @adbm_databases.nil?
      result = self.class.get("/_api/user/#{@adbm_user}/database", @adbm_request)
      raise "Error fetching databases" unless result.code.between?(200, 299)
      result = result.parsed_response
      res = result["result"].map{|k,v| {obj: 'DB', name: k, access: v}}
      @adbm_databases = res
    end

    return @adbm_databases
  end

  def adbm_database_access(database_name)
    @adbm_database_access = {} if @adbm_database_access.nil?

    if @adbm_database_access[database_name].nil?
      result = self.class.get("/_api/user/#{@adbm_user}/database/#{database_name}", @adbm_request)
      return "" unless result.code.between?(200, 299)
      access = result.parsed_response["result"]
      @adbm_database_access[database_name] = access
    end

    return @adbm_database_access[database_name]
  end

  def adbm_database_has_access(database_name, acc_type_arr)
    access = adbm_database_access(database_name)

    puts "adbm_database_has_access() user:#{@adbm_user} database:#{database_name} of type:#{access} ... required:#{acc_type_arr.to_s}"
    acc_type_arr.each do |acc_type|
      return true if acc_type == access
    end
    puts "adbm_database_has_access() NO ACCESS"
    return false
  end

  def adbm_collection_access(database_name, collection_name)
    @adbm_collection_access = {} if @adbm_collection_access.nil?
    @adbm_collection_access[database_name] = {} if @adbm_collection_access[database_name].nil?

    if @adbm_collection_access[database_name][collection_name].nil?
      result = self.class.get("/_api/user/#{@adbm_user}/database/#{database_name}/#{collection_name}", @adbm_request)
      return "" unless result.code.between?(200, 299)
      access = result.parsed_response["result"]
      @adbm_collection_access[database_name][collection_name] = access
    end
    return @adbm_collection_access[database_name][collection_name]
  end

  def adbm_collection_has_access(database_name, collection_name, acc_type_arr)
    access = adbm_collection_access(database_name, collection_name)

    puts "adbm_database_has_access() user:#{@adbm_user} database:#{database_name} of type:#{access} ... required:#{acc_type_arr.to_s}"
    acc_type_arr.each do |acc_type|
      return true if acc_type == access
    end
    puts "adbm_database_has_access() NO ACCESS"
    return false
  end

  def adbm_collections(database_name: nil, excludeSystem: true)
    return [] unless adbm_database_has_access(database_name , ["rw", "ro"])

    @adbm_collections = {} if @adbm_collections.nil?

    if @adbm_collections[database_name].nil?
      query = { "excludeSystem": excludeSystem }.delete_if{|k,v| v.nil?}
      request = @adbm_request.merge({ :query => query })
      result = self.class.get("/_db/#{database_name}/_api/collection", request)
      raise "Error fetching collections" unless result.code.between?(200, 299)

      result = result.parsed_response
      res = result["result"].map{|x| {obj: 'COLL', db: database_name, collection: x["name"], type: x['type'] == 3 ? 'Edge' : 'Document'}}
      @adbm_collections[database_name] = res
    end
    return @adbm_collections[database_name]
  end

  def adbm_collection_create(db_name, coll_name, type, journalSize: nil, keyOptions: nil, waitForSync: nil, doCompact: nil, isVolatile: nil, shardKeys: nil, numberOfShards: nil, isSystem: nil, indexBuckets: nil)

    raise "No R/W access to database" unless adbm_database_has_access(db_name , ["rw"])
    raise "Existing collection" unless adbm_collection_access(db_name, coll_name) != ""

    type = 3 if type == "Edge"
    type = nil if type == "Document"
    body = {
      "name" => coll_name,
      "type" => type,
      "journalSize" => journalSize,
      "keyOptions" => keyOptions,
      "waitForSync" => waitForSync,
      "doCompact" => doCompact,
      "isVolatile" => isVolatile,
      "shardKeys" => shardKeys,
      "numberOfShards" => numberOfShards,
      "isSystem" => isSystem,
      "indexBuckets" => indexBuckets
    }
    body = body.delete_if{|k,v| v.nil?}.to_json
    request = @adbm_request.merge({ :body => body })

    result = self.class.post("/_db/#{db_name}/_api/collection", request)
    adbm_clear # Clear all cache
    raise "Error creating collection info '#{result["errorMessage"]}'" unless result.code.between?(200, 299)
    result = result.parsed_response
  end

  def adbm_collection_info(db_name, coll_name)
    result = self.class.get("/_db/#{db_name}/_api/collection/#{coll_name}/count", @adbm_request)
    raise "Error fetching collection info" unless result.code.between?(200, 299)
    result = result.parsed_response
  end

  def adbm_collection_delete(db_name, coll_name)
    raise "No R/W access to collection" unless adbm_collection_has_access(db_name, coll_name, ["rw"])
    result = self.class.delete("/_db/#{db_name}/_api/collection/#{coll_name}", @adbm_request)
    adbm_clear # Clear all cache
    raise "Error deleting collection" unless result.code.between?(200, 299)
    result = result.parsed_response
  end

  def adbm_document_importJSON(db_name, coll_name, body, type: "auto", from: nil, to: nil, overwrite: nil, waitForSync: nil, onDuplicate: nil, complete: nil, details: nil)

    raise "No R/W access to collection" unless adbm_collection_has_access(db_name, coll_name, ["rw"])

    query = {
      "collection": coll_name,
      "type": type,
      "fromPrefix": from,
      "toPrefix": to,
      "overwrite": overwrite,
      "waitForSync": waitForSync,
      "onDuplicate": onDuplicate,
      "complete": complete,
      "details": details
    }.delete_if{|k,v| v.nil?}
    request = @adbm_request.merge({ :body => body, :query => query })
    result = self.class.post("/_db/#{db_name}/_api/import", request)
    raise "Error storing document into collection" unless result.code.between?(200, 299)
    result = result.parsed_response
  end




  def adbm_database_query(db_name, query_string)
    raise "No read access to database" unless adbm_database_has_access(db_name, ["rw", "ro"])

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
    raise result.parsed_response["errorMessage"] unless result.code.between?(200, 299)
    result = result.parsed_response
    @quantity = result["count"]
    @hasMore = result["hasMore"]
    @id = result["id"]
    return result
  end

end
