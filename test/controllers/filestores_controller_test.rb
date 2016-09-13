require 'test_helper'

class FilestoresControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include ThingHelper
  setup do
    # create a test user if it doesn't exist and sign in
    @user = create_test_user_if_not_exists
    sign_in @user

    # use a filestore for testing
    @filestore = Filestore.new
    @filestore.user = @user
    # TODO - Add a file here
    @filestore.save(:validate => false)
  end

  test "should get index" do
    get :index, params: { username: @user.username }
    assert_response :success
    assert_not_nil assigns(:filestores)
  end

  #  GET /:username/:resource/new
  test "should get new" do
    get :new, params: { username: @user.username, resource: 'filestores' }
    assert_response :success
  end

  # POST /:username/:resource/
  test "should create filestore" do
    assert_difference('Filestore.count') do
      post :create, params: {
        username: @user.username, resource: 'filestores',
        filestore: {
          name: 'A new public file',
          public: true
          }
        }
    end

    assert_redirected_to filestore_path(Filestore.last)
  end

  # GET /:username/:resource/:id
  test "should show filestore" do
    get :show, params: { username: @user.username, resource: 'filestore', id: @filestore.id }
    assert_response :success
  end

  # GET /:username/:resource/:id/edit
  test "should get edit" do
    get :edit, params: { username: @user.username, resource: 'filestore', id: @filestore.id }
    assert_response :success
  end

  # PATCH/PUT /:username/:resource/:id
  test "should update transformation" do
    patch :update,
    params: {
      username: @user.username, resource: 'filestores', id: @filestore.id,
      filestore: {
        name: 'A new public file',
        public: true
        }
      }
    assert_redirected_to filestore_path(assigns(:filestore))
  end
  # DELETE /:username/:resource/:id
  test "should destroy file" do
    assert_difference('Filestore.count', -1) do
      delete :destroy, params: { username: @user.username, resource: 'filestores', id: @filestore.id}
    end

    assert_redirected_to things_path(@filestore)
  end

end
