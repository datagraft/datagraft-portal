require 'test_helper'

class DbmArangoAccessTest < ActiveSupport::TestCase
  setup do
    puts "Do setup ..."
    # Check that db is clean
    accounts = DbmAccount.all
    assert accounts.size == 0, "Old DbmAccounts are detected"

    dbmarango = DbmArango.all
    assert dbmarango.size == 0, "Old DbmArango are detected"

    # Create a user for testing
    @testUser = create_test_user_if_not_exists

    @testDbmArango = create_test_dbm_arango(@testUser)

    @testAccountRw = @testDbmArango.add_account(get_test_dbm_arango_rw_user, get_test_dbm_arango_rw_pwd, true)
    @testAccountRo = @testDbmArango.add_account(get_test_dbm_arango_ro_user, get_test_dbm_arango_ro_pwd, true)
    @testAccountRo.public = true
    @testAccountRo.save

    @testDbName = get_test_dbm_arango_db_name

    # Remove any collections created in previous tests
    delete_test_dbm_arango_collections(@testDbmArango, @testDbName)

  end

  teardown do
    puts "Do teardown ..."

    # When controller is using cache it may be a good idea to reset it afterwards
    Rails.cache.clear

  end

  test "create and delete collection success path" do

    collection_name = "test_doc_coll"

    coll_arr = @testDbmArango.get_collections(@testDbName, false)
    assert coll_arr.count == 0, "There shall not be any initial collections found:#{coll_arr.size}"

    ### Create collection
    create_collection(collection_name, "document")

    ### Check the collection
    # Check using RW user
    coll_arr = @testDbmArango.get_collections(@testDbName, false)
    assert coll_arr.count == 1, "There shall only be one collection found:#{coll_arr.size}"
    coll = coll_arr.first

    assert coll[:name] == "test_doc_coll", "Wrong dcoument type found:#{coll[:name]}"
    assert coll[:type] == "document", "Wrong document type found:#{coll[:type]}"
    assert coll[:access] == 'rw', "Wrong access found:#{coll[:access]}"

    # Check using RO user
    coll_arr = @testDbmArango.get_collections(@testDbName, true)
    assert coll_arr.count == 1, "There shall only be one collection found:#{coll_arr.size}"
    coll = coll_arr.first
    assert coll[:name] == "test_doc_coll", "Wrong dcoument type found:#{ coll[:name]}"
    assert coll[:type] == "document", "Wrong dcoument type found:#{coll[:type]}"
    assert coll[:access] == 'ro', "Wrong access found:#{coll[:access]}"

    ### Delete the collection
    delete_collection(coll)

    coll_arr = @testDbmArango.get_collections(@testDbName, false)
    assert coll_arr.count == 0, "There shall not be any collections after delete found:#{coll_arr.size}"

  end

  test "upload and query doc data success path" do
    ### Create doc collection
    collection_name = "test_doc_coll"
    create_collection(collection_name, "document")

    coll_arr = @testDbmArango.get_collections(@testDbName, false)
    coll = coll_arr.first
    assert coll_arr.count == 1, "There shall only be one collection found:#{coll_arr.size}"

    ### Upload data
    upload_file("arango_value_short.json", @testDbName, coll)

    ### Query data

    query_string = "FOR u IN #{collection_name} FILTER u.__type == 'Property' RETURN { 'label' : u.label }"
    result = @testDbmArango.query_database(@testDbName, query_string, false)
    assert result["result"].count == 1, "Expected one match found:#{result["result"].count}"

    ### Delete doc collection(s)
    coll_arr = @testDbmArango.get_collections(@testDbName, false)
    coll_arr.each do |coll|
      delete_collection(coll)
    end

    coll_arr = @testDbmArango.get_collections(@testDbName, false)
    assert coll_arr.count == 0, "There shall not be any collections after delete found:#{coll_arr.size}"

  end



  test "upload and query edge data success path" do
    ### Create doc collection
    collection_doc_name = "test_doc_coll"
    create_collection(collection_doc_name, "document")

    coll_arr = @testDbmArango.get_collections(@testDbName, false)
    assert coll_arr.count == 1, "There shall only be one collection found:#{coll_arr.size}"

    ### Create edge collection
    collection_edge_name = "test_edge_coll"
    create_collection(collection_edge_name, "edge")

    coll_arr = @testDbmArango.get_collections(@testDbName, false)
    assert coll_arr.count == 2, "There shall be two collection found:#{coll_arr.size}"

    ### Upload data
    coll_doc = getColl(collection_doc_name)
    upload_file("arango_value_short.json", @testDbName, coll_doc)
    coll_edge = getColl(collection_edge_name)
    upload_file("arango_edge_short.json", @testDbName, coll_edge, collection_doc_name)

    ### Query data
    query_string = "FOR u IN #{collection_edge_name} FILTER u._from == \'#{collection_doc_name}/0\' RETURN { 'to' : u._to }"
    result = @testDbmArango.query_database(@testDbName, query_string, false)
    assert result["result"].count == 2, "Expected one match found:#{result["result"].count}"

    ### Delete doc collection(s)
    coll_arr = @testDbmArango.get_collections(@testDbName, false)
    coll_arr.each do |coll|
      delete_collection(coll)
    end

    coll_arr = @testDbmArango.get_collections(@testDbName, false)
    assert coll_arr.count == 0, "There shall not be any collections after delete found:#{coll_arr.size}"

  end

  test "create a collection dbm_access problems" do
  end

  test "create a collection uri problems" do
  end



  ########################
  private
  ########################


  def create_collection(collection_name, type)
    coll_arr_before = @testDbmArango.get_collections(@testDbName, false)

    ### Create collection
    assert_raises(StandardError) do
      @testDbmArango.create_collection(@testDbName, collection_name, type, true) # Create with RO user shall fail
    end

    @testDbmArango.create_collection(@testDbName, collection_name, type, false) # Create a document collection

    coll_arr_after = @testDbmArango.get_collections(@testDbName, false)

    assert coll_arr_before.count+1 == coll_arr_after.count, "Failed to create new collection name:#{collection_name} type:#{type}"

  end

  def getColl(coll_name)
    res = nil
    coll_arr = @testDbmArango.get_collections(@testDbName, false)
    coll_arr.each do |coll|
      res = coll if coll[:name] == coll_name
    end
    return res
  end

  def upload_file(file_name, db_name, coll, from_to_coll_prefix=nil)
    json_option = "auto"
    overwrite_option = nil
    on_duplicate_option = "error"
    complete_option = "true"
    json_file = file_fixture(file_name)

    info = @testDbmArango.get_collection_info(coll: coll, public: false)
    size_before = info['count']

    if coll[:type] == "document"
      assert_raises(StandardError) do
        result = @testDbmArango.upload_document_data(json_file, db_name, coll[:name], true, json_option, overwrite_option, on_duplicate_option, complete_option)  # Upload with RO user shall fail
      end
      result = @testDbmArango.upload_document_data(json_file, db_name, coll[:name], false, json_option, overwrite_option, on_duplicate_option, complete_option)
    else
      assert_raises(StandardError) do
        result = @testDbmArango.upload_edge_data(json_file, db_name, coll[:name], from_to_coll_prefix, from_to_coll_prefix, true, json_option, overwrite_option, on_duplicate_option, complete_option)  # Upload with RO user shall fail
      end
      result = @testDbmArango.upload_edge_data(json_file, db_name, coll[:name], from_to_coll_prefix, from_to_coll_prefix, false, json_option, overwrite_option, on_duplicate_option, complete_option)
    end
    info = @testDbmArango.get_collection_info(coll: coll, public: false)
    size_rw_after = info['count']
    assert size_rw_after > size_before, "Collection size not changed after upload"

    info = @testDbmArango.get_collection_info(db_name: db_name, collection_name: coll[:name], public: true)
    size_ro_after = info['count']
    assert size_rw_after == size_ro_after, "Collection size differs for RW and RO access"
  end

  def delete_collection(coll)
    assert_raises(StandardError) do
      @testDbmArango.delete_collection(coll, true) # Delete with RO user shall fail
    end

    @testDbmArango.delete_collection(coll, false)
  end

end
