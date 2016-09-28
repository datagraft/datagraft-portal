require 'test_helper'

class SparqlEndpointsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include ThingHelper
  setup do
    # Create a test user if it doesn't exist and sign in
    @user = create_test_user_if_not_exists
    sign_in @user
    
    # Create a sparql endpoint for testing
    @se = SparqlEndpoint.new
    @se.user = @user
    @se.save(:validate => false)
    
    # Test parameters
    @se_public = true
    @se_name = 'SE test'
    @se_description = 'SE description'
    @se_license = 'CC0'
    @se_keyword_list = 'key1, key2'
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
  
=begin
  # TODO: Needs a test user with ontotext account to be able to create the SPARQL endpoint (Ontotext API)
  # POST /:username/:resource/
  test "should create sparql endpoint" do
    assert_difference('SparqlEndpoint.count') do
      post :create, params: {
        username: @user.username, resource: 'sparql_endpoints',
        sparql_endpoint: {
          public: @se_public, 
          name: @se_name, 
          description: @se_description, 
          license: @se_license, 
          keyword_list: @se_keyword_list
        }
      }
    end
    assert_redirected_to thing_path(assigns(:sparql_endpoint))
  end
=end
  
=begin
  # TODO: Needs a test user with ontotext account to be able to get size of SPARQL endpoint (Ontotext API)
  # GET /:username/:resource/:id
  test "should show sparql endpoint" do
    get :show, params: { 
      username: @user.username,
      resource: 'sparql_endpoints',
      id: @se.id 
    }
    assert_response :success
  end
=end
  
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
    assert_redirected_to things_path(@se)
  end
  
end
