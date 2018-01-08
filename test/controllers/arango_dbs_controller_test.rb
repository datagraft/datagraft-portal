require 'test_helper'

class ArangoDbsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include ThingHelper
  setup do
    puts "Do setup ..."

    # Create a test user if it doesn't exist and sign in
    @user = create_test_user_if_not_exists
    sign_in @user

    accounts = DbmAccount.all
    assert accounts.size == 0, "Old DbmAccounts are detected"

    dbmarango = DbmArango.all
    assert dbmarango.size == 0, "Old DbmArango are detected"

    @testDbmArango = create_test_dbm_arango(@user)

    @testAccountRw = @testDbmArango.add_account(get_test_dbm_arango_rw_user, get_test_dbm_arango_rw_pwd, true)
    @testAccountRo = @testDbmArango.add_account(get_test_dbm_arango_ro_user, get_test_dbm_arango_ro_pwd, true)
    @testAccountRo.public = true
    @testAccountRo.save

    @testDbName = get_test_dbm_arango_db_name

    # Remove any collections created in previous tests
    delete_test_dbm_arango_collections(@testDbmArango, @testDbName)

    # Create a arango_db for testing
    @adb = ArangoDb.new
    @adb.user = @user
    @adb.dbm = @testDbmArango
    @adb.db_name = get_test_dbm_arango_db_name

    @adb.save(:validate => false)

    # Test parameters
    @adb_public = true
    @adb_name = 'ADB test'
    @adb_description = 'ADB description'
    @adb_license = 'CC0'
    @adb_keyword_list = 'key1, key2'
    @adb.save(:validate => false)

  end

  teardown do
    puts "Do teardown ..."

    # When controller is using cache it may be a good idea to reset it afterwards
    Rails.cache.clear

  end


  test "should get index" do
    get :index, params: {
      username: @user.username,
      resource: 'arango_dbs'
    }
    assert_response :success
    assert_not_nil assigns(:arango_dbs)
  end

  # GET /:username/:resource/new
  test "should get new arango_db" do
    get :new, params: {
      username: @user.username,
      resource: 'arango_dbs'
    }
    assert_response :success
  end

  # POST /:username/:resource/
  test "should fail_create_arango_db_missing_db" do
    assert_no_difference('ArangoDb.count') do
      post :create, params: {
        username: @user.username,
        resource: 'arango_dbs',
        arango_db: {
          public: @adb_public,
          name: @adb_name,
          description: @adb_description,
          license: @adb_license
        }
      }
    end
    assert_response :success
  end

  # POST /:username/:resource/
  test "should create private_arango db" do
    assert_difference('ArangoDb.count') do
      get :new, params: {
        username: @user.username,
        resource: 'arango_dbs'
      }
      db_entries = assigns("db_entries") # Get list over valid databases

      post :create, params: {
        username: @user.username,
        resource: 'arango_dbs',
        arango_db: {
          public: false,
          db_entries: db_entries.first[1], # Select first database
          name: @adb_name,
          description: @adb_description,
          license: @adb_license
        }
      }
    end
    new_thing = assigns(:thing)
    assert_redirected_to thing_path(new_thing)

  end

  # GET /:username/:resource/:id
  test "should show arango db" do
    get :show, params: {
      username: @user.username,
      resource: 'arango_dbs',
      id: @adb.id
    }
    assert_response :success
  end

  # GET /:username/:resource/:id/edit
  test "should get edit arango db" do
    get :edit, params: {
      username: @user.username,
      resource: 'arango_dbs',
      id: @adb.id
    }
    assert_response :success
  end

  # PATH/PUT /:username/:resource/:id
  test "should update arango db" do
    patch :update, params: {
      username: @user.username,
      resource: 'arango_dbs',
      id: @adb.id,
      arango_db: {
        public: @adb_public,
        name: @adb_name,
        description: @adb_description,
        license: @adb_license,
        keyword_list: @adb_keyword_list
      }
    }
    assert_redirected_to thing_path(assigns(:arango_db))
  end

  # DELETE /:username/:resource/:id
  test "should delete arango db" do
    assert_difference('ArangoDb.count', -1) do
      delete :destroy, params: {
        username: @user.username,
        resource: 'arango_dbs',
        id: @adb.id
      }
    end
    assert_redirected_to dashboard_path
  end

  # GET      /:username/arango_dbs/:id/collection/new
  test "should get new arango_db collection" do
    get :collection_new, params: {
      username: @user.username,
      resource: 'arango_dbs',
      id: @adb.id
    }
    assert_response :success
  end

  # POST      /:username/arango_dbs/:id/collection
  test "should create new arango_db collection and query" do
    doc_collection_name = 'coll_doc'
    edge_collection_name = 'coll_edge'

    # Create collections
    create_collection('document', doc_collection_name)
    create_collection('edge', edge_collection_name)

    #Check collection_publish_new
    get :collection_publish_new, params: {
      username: @user.username,
      resource: 'arango_dbs',
      id: @adb.id,
      collection_name: doc_collection_name
    }
    assert_response :success



    # Upload to collections
    publish_to_collection("files/arango_value_short.json", doc_collection_name)
    publish_to_collection("files/arango_edge_short.json", edge_collection_name, doc_collection_name)

    # Query collections
    post :execute_query, params: {
      username: @user.username,
      resource: 'arango_dbs',
      id: @adb.id,
      collection_name: doc_collection_name,
      execute_query: {
        query_string: "FOR u IN #{doc_collection_name} FILTER u.__type == 'Property' RETURN { 'label' : u.label }"
      }
    }
    assert_response :success
    results_list = assigns('results_list')
    assert results_list.count == 1, "Failed query doc collection"


    post :execute_query, params: {
      username: @user.username,
      resource: 'arango_dbs',
      id: @adb.id,
      collection_name: edge_collection_name,
      execute_query: {
        query_string: "FOR u IN #{edge_collection_name} FILTER u._from == \'#{doc_collection_name}/0\' RETURN { 'to' : u._to }"
      }
    }
    assert_response :success
    results_list = assigns('results_list')
    assert results_list.count == 2, "Failed query edge collection"


    # Delete the collection
    delete :collection_destroy, params: {
      username: @user.username,
      resource: 'arango_dbs',
      id: @adb.id,
      collection_name: doc_collection_name,
    }
    assert_redirected_to thing_edit_path(assigns(:arango_db))


  end




  private

    def get_collection_info
      # Check current number of collections
      get :show, params: {
        username: @user.username,
        resource: 'arango_dbs',
        id: @adb.id
      }
      assert_response :success

      res = assigns("coll_info_list") # Get list over valid databases
      return res
    end

    def create_collection(coll_type, coll_name)

      # Get current number of collections
      before_coll_count = get_collection_info.count

      post :collection_create, params: {
        username: @user.username,
        resource: 'arango_dbs',
        id: @adb.id,
        arango_db: {
          coll_type: coll_type,
          coll_name: coll_name
        }
      }
      assert_redirected_to thing_edit_path(assigns(:arango_db))

      # Check that the collection was created
      after_coll_count = get_collection_info.count
      assert before_coll_count+1 == after_coll_count, "Failed to create collection"
    end

    def publish_to_collection(filename, coll_name, from_to_coll_prefix="")

      json_file = fixture_file_upload(filename, 'application/json')

      post :collection_publish, params: {
        username: @user.username,
        resource: 'arango_dbs',
        id: @adb.id,
        collection_name: coll_name,
        arango_db: {
          publish_file: json_file,
          json_option: 'auto',
          from_to_coll_prefix: from_to_coll_prefix
        }
      }

      assert_response :success

    end
end
