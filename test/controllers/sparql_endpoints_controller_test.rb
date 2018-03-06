require 'test_helper'

class SparqlEndpointsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include ThingHelper
  setup do
    puts "Do setup ..."
    # Create a test user if it doesn't exist and sign in
    @user = create_test_user_if_not_exists
    sign_in @user

    @testDbmS4 = create_test_dbm_s4(@user)
    @testKey = @testDbmS4.add_key('TestS4Key', get_test_dbm_s4_key, get_test_dbm_s4_secret, true)
    @testRdfRepoUrl = nil  # Assign this when creating external repository
    # puts "Current first ApiKey: #{@testDbmS4.api_keys.first.inspect}"

    # Create a sparql endpoint for testing
    @se = SparqlEndpoint.new
    @se.user = @user
    @se.name = 'SE init name'
    @se.save(:validate => false)
    # puts "Current @se.slug: #{@se.slug}"

    # Test parameters
    @se_public = true
    @se_name = 'SE test wo db'
    @se_description = 'SE description wo db'
    @se_license = 'CC0'
    @se_keyword_list = 'key1, key2'
    # @se.save(:validate => false)




  end

  teardown do
    puts "Do teardown ..."

    # Cleanup using the url from the test object

    delete_test_dbm_s4_repository(@testDbmS4, @testRdfRepoUrl)
    # When controller is using cache it may be a good idea to reset it afterwards
    Rails.cache.clear

  end


  test "should get index" do
    get :index, params: { username: @user.username }
    assert_response :success
    assert_not_nil assigns(:sparql_endpoints)
  end

  # GET /:username/:resource/new
  test "should get new sparql endpoint" do
    get :new, params: {
      username: @user.username,
      resource: 'sparql_endpoints'
    }
    assert_response :success
  end

  # POST /:username/:resource/
  test "should fail_create_sparql endpoint_missing_dbm" do
    post :create, params: {
      username: @user.username,
      resource: 'sparql_endpoints',
      sparql_endpoint: {
        public: false,
        name: 'SE name',
        description: 'SE description',
        license: 'CC0'
      }
    }
    assert_redirected_to dashboard_path
  end

  # POST /:username/:resource/
  test "should create private_sparql endpoint" do
    assert_difference('SparqlEndpoint.count') do
      post :create, params: {
        username: @user.username,
        resource: 'sparql_endpoints',
        sparql_endpoint: {
          public: false,
          dbm_entries: @testDbmS4.id,
          name: 'SE name',
          description: 'SE description',
          license: 'CC0'
        }
      }
    end
    new_thing = assigns(:thing)
    assert_redirected_to thing_path(new_thing)

    repo_success = wait_for_repo_to_become_ready(new_thing)
    assert repo_success == true, "Failed to create repo"

  end

  # GET /:username/:resource/:id
  test "should show sparql endpoint" do
    get :show, params: {
      username: @user.username,
      resource: 'sparql_endpoints',
      id: @se.id
    }
    assert_response :success
  end

  # GET /:username/:resource/:slug/state
  test "should get sparql endpoint state" do
    # Test polling of state
    puts "Current state @se.slug: #{@se.slug} @se.state: #{@se.state}"
    get :state, :format => 'json', params: {
      username: @user.username,
      resource: 'sparql_endpoints',
      slug: @se.slug
    }
    r = ActiveSupport::JSON.decode @response.body
    ret = r["state"]
    assert ret == @se.state, "Failed to fetch state"
    puts "Got state:'#{ret}'"
  end

  # GET /:username/:resource/:slug/url
  test "should get sparql endpoint url" do
    # Test polling of url
    puts "Current url @se.slug: #{@se.slug} @se.url: #{@se.uri}"
    get :url, :format => 'json', params: {
      username: @user.username,
      resource: 'sparql_endpoints',
      slug: @se.slug
    }
    r = ActiveSupport::JSON.decode @response.body
    ret = r["url"]
    assert ret == @se.uri, "Failed to fetch url"
    puts "Got url:'#{ret}'"
  end

  # GET /:username/:resource/:id/edit
  test "should get edit sparql endpoint" do
    get :edit, params: {
      username: @user.username,
      resource: 'sparql_endpoints',
      id: @se.id
    }
    assert_response :success
  end

  # PATH/PUT /:username/:resource/:id
  test "should update sparql endpoint" do
    patch :update, params: {
      username: @user.username,
      resource: 'sparql_endpoints',
      id: @se.id,
      sparql_endpoint: {
        public: @se_public,
        name: @se_name,
        description: @se_description,
        license: @se_license,
        keyword_list: @se_keyword_list
      }
    }
    assert_redirected_to thing_path(assigns(:sparql_endpoint))
  end

  # DELETE /:username/:resource/:id
  test "should delete sparql endpoint" do
    assert_difference('SparqlEndpoint.count', -1) do
      delete :destroy, params: {
        username: @user.username,
        resource: 'sparql_endpoints',
        id: @se.id
      }
    end
    assert_redirected_to dashboard_path
  end

  private

  def wait_for_repo_to_become_ready(new_thing)
    retries = 90
    repo_ready = false
    puts "Waiting for repo to become ready #{retries} seconds"
    while retries > 0 and !repo_ready do
      sleep(1)  # Wait some time so background thead gets ready
      @testRdfRepoUrl = new_thing.rdf_repo.uri
      ret = new_thing.state
      repo_ready = true if ret == "repo_created"
      repo_ready = true if ret == "error_creating_repo"
      retries -= 1
      puts "********** wait_for_repo_to_become_ready() retries:#{retries} state:#{ret} uri:#{@testRdfRepoUrl} **********"
    end
    puts "Ended wait after #{90-retries} seconds"
    sleep(1)  # Wait some time so background thead terminates
    return ret == "repo_created"
  end

end
