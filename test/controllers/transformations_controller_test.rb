require 'test_helper'

class TransformationsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include TransformationsHelper
  include ThingHelper
  setup do
    # create a test user if it doesn't exist and sign in
    @user = create_test_user_if_not_exists
    sign_in @user
    
    # use a transformation for testing
    @transformation = Transformation.new
    @transformation.user = @user
    @transformation.save(:validate => false) 
  end

  test "should get index" do
    get :index, params: { username: @user.username }
    assert_response :success
    assert_not_nil assigns(:transformations)
  end

  #  GET /:username/:resource/new
  test "should get new" do
    get :new, params: { username: @user.username, resource: 'transformations' }
    assert_response :success
  end

  # POST /:username/:resource/
  test "should create transformation" do
    assert_difference('Transformation.count') do
      post :create, params: {
        username: @user.username, resource: 'transformations', 
        transformation: { 
          name: 'A new public transformation',
          public: true
          }
        }
    end

    assert_redirected_to transformation_path(assigns(:transformation))
  end

  # GET /:username/:resource/:id
  test "should show transformation" do
    get :show, params: { username: @user.username, resource: 'transformations', id: @transformation.id }
    assert_response :success
  end

  # GET /:username/:resource/:id/edit
  test "should get edit" do
    get :edit, params: { username: @user.username, resource: 'transformations', id: @transformation.id}
    assert_response :success
  end

  # PATCH/PUT /:username/:resource/:id
  test "should update transformation" do
    patch :update, 
    params: {
      username: @user.username, resource: 'transformations', id: @transformation.id, 
      transformation: {
        name: 'A new public transformation',
        public: true
        } 
      }
    assert_redirected_to transformation_path(assigns(:transformation))
  end
  # DELETE /:username/:resource/:id
  test "should destroy transformation" do
    assert_difference('Transformation.count', -1) do
      delete :destroy, params: { username: @user.username, resource: 'transformations', id: @transformation.id }
    end

    assert_redirected_to things_path(@transformation)
  end

end
