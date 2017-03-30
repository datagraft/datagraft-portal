require 'test_helper'

class ApiKeysControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include ThingHelper
  setup do
    # Create a test user if it doesn't exist and sign in
    @user = create_test_user_if_not_exists
    sign_in @user
    
    # Create an api key for testing
    @api_key = api_keys(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:api_keys)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

=begin
  # TODO: Needs a test user with ontotext account to be able to test API keys
  # TODO: Problem with Faraday::TimeoutError: Net::ReadTimeout for the Ontotext API
  test "should create api_key" do
    assert_difference('ApiKey.count') do
      post :create, api_key: { enabled: @api_key.enabled, key: @api_key.key, name: @api_key.name, user_id: @api_key.user_id }
    end

    assert_redirected_to api_key_path(assigns(:api_key))
  end

  test "should show api_key" do
    get :show, id: @api_key
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @api_key
    assert_response :success
  end

  test "should update api_key" do
    patch :update, id: @api_key, api_key: { enabled: @api_key.enabled, key: @api_key.key, name: @api_key.name, user_id: @api_key.user_id }
    assert_redirected_to api_key_path(assigns(:api_key))
  end

  test "should destroy api_key" do
    assert_difference('ApiKey.count', -1) do
      delete :destroy, id: @api_key
    end

    assert_redirected_to api_keys_path
  end
=end
  
end
