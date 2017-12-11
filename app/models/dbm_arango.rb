
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
  def create_collection(db_name, collection_name, type)
    puts "***** Enter DbmArango.create_collection(#{name})"
    res = adbm_collection_create(db_name, collection_name, type)
    puts "***** Exit DbmArango.create_collection()"
    return res
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

  def get_collection_info(coll: nil, db_name: nil, collection_name: nil)
    puts "***** Enter DbmArango.get_collection_status(#{name})"
    db_name = coll[:database][:name] unless coll.nil?
    collection_name = coll[:name] unless coll.nil?

    info = adbm_collection_info(db_name, collection_name)
    puts "***** Exit DbmArango.get_collection_status()"
    return info
  end

  # Delete collection
  def delete_collection(coll)
    puts "***** Enter DbmArango.delete_collection(#{name})"
    info = adbm_collection_delete(coll[:database][:name], coll[:name])
    puts "***** Exit DbmArango.delete_collection()"
    return info
  end

  def upload_document_data_array(jsonFile, db_name, coll_name)
    puts "***** Enter DbmArango.upload_document_data_array(#{name})"
    body = jsonFile.read
    waitForSync = nil
    onDuplicate = "replace"
    complete = "yes"

    res = adbm_document_importJSON(db_name, coll_name, body, waitForSync: waitForSync, onDuplicate: onDuplicate, complete: complete)
    puts "***** Exit DbmArango.upload_document_data_array(#{name})"
    return res
  end

  def upload_edge_data_array(jsonFile, db_name, coll_name, from_coll_name, to_coll_name)
    puts "***** Enter DbmArango.upload_edge_data_array(#{name})"
    body = jsonFile.read
    waitForSync = nil
    onDuplicate = "replace"
    complete = "yes"

    res = adbm_document_importJSON(db_name, coll_name, body, waitForSync: waitForSync, onDuplicate: onDuplicate, complete: complete, from: from_coll_name, to: to_coll_name)
    puts "***** Exit DbmArango.upload_edge_data_array(#{name})"
    return res
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
    "#{@adbm_uri}/_db/#{db_name}"
  end

  # Query specific database
  def query_database(db_name, query_string)
    puts "***** Enter DbmArango.query_database(#{name})"
    response = adbm_database_query(db_name, query_string)

    puts "***** Exit DbmArango.query_database()"
    return response
  end


  private

  def adbm_init
    if @adbm_init.nil?
      puts "***** adbm_init(#{name})"
      da = first_enabled_account
      @adbm_uri = uri
      self.class.base_uri "#{@adbm_uri}"

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

  def adbm_collection_create(db_name, coll_name, type, journalSize=nil, keyOptions=nil, waitForSync=nil, doCompact=nil, isVolatile=nil, shardKeys=nil, numberOfShards=nil, isSystem=nil, indexBuckets=nil)

    adbm_init

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
    raise "Error creating collection info '#{result["errorMessage"]}'" unless result.code.between?(200, 299)
    result = result.parsed_response
  end

  def adbm_collection_info(db_name, coll_name)
    adbm_init
    result = self.class.get("/_db/#{db_name}/_api/collection/#{coll_name}/count", @adbm_request)
    raise "Error fetching collection info" unless result.code.between?(200, 299)
    result = result.parsed_response
  end

  def adbm_collection_delete(db_name, coll_name)
    adbm_init
    result = self.class.delete("/_db/#{db_name}/_api/collection/#{coll_name}", @adbm_request)
    raise "Error deleting collection" unless result.code.between?(200, 299)
    result = result.parsed_response
  end

  def adbm_document_importJSON(db_name, coll_name, body, type: "auto", from: nil, to: nil, overwrite: nil, waitForSync: nil, onDuplicate: nil, complete: nil, details: nil)
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
