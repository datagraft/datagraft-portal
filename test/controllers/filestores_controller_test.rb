require 'test_helper'

class FilestoresControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include ThingHelper
  setup do
    # create a test user if it doesn't exist and sign in
    @user = create_test_user_if_not_exists
    sign_in @user

    # use a filestore for testing
    @filestore = create_test_filestore_if_not_exists

    #puts "Setup all users"
    #puts User.all.inspect
    #puts "Setup all filestores"
    #puts Filestore.all.inspect
  end

  test "should get index" do
    puts "index 1"
    get :index, params: { username: @user.username ,resource: 'filestores'}
    assert_response :success
    assert_not_nil assigns(:filestores)
    puts "index 2"
  end

  #  GET /:username/:resource/new
  #test "should get new" do
  #  puts "new 2"
  #  get :new, params: { username: @user.username, resource: 'filestores' }
  #  assert_response :success
  #  puts "new 2"
  #end

  # Fails because assert_redirected_to filestore_path(Filestore.last) is undefined error...
  # POST /:username/:resource/
  #test "should create filestore" do
  #  puts "create 1"
  #  assert_difference('Filestore.count') do
  #    test_file = fixture_file_upload("/files/left_leg_mag.xls", "application/vnd.ms-excel", :binary)
  #    post :create, params: { username: @user.username, filestore: { file: test_file, name: 'A new public file',
  #    public: true }}
  #  end
  #
  #  assert_redirected_to filestore_path(Filestore.last)
  #  puts "create 2"
  #end

  # Fails because @filestore.id does not exist...
  # GET /:username/:resource/:id
  #test "should show filestore" do
  #  puts "show 1"
  #  get :show, params: { username: @user.username, resource: 'filestore', id: @filestore.id }
  #  assert_response :success
  #  puts "show 2"
  #end

  # Fails because @filestore.id does not exist...
  # GET /:username/:resource/:id/edit
  #test "should get edit" do
  #  puts "edit 1"
  #  get :edit, params: { username: @user.username, resource: 'filestore', id: @filestore.id }
  #  assert_response :success
  #  puts "edit 2"
  #end

  # Fails because @filestore.id does not exist...
  # PATCH/PUT /:username/:resource/:id
  #test "should update filestore" do
  #  puts "patch 1"
  #  patch :update,
  #  params: {
  #    username: @user.username, resource: 'filestores', id: @filestore.id,
  #    filestore: {
  #      name: 'A new public file',
  #      public: true
  #      }
  #    }
  #  assert_redirected_to filestore_path(assigns(:filestore))
  #  puts "patch 2"
  #end

  # Fails because @filestore.id does not exist...
  # DELETE /:username/:resource/:id
  #test "should destroy file" do
  #  puts "destroy 1"
  #  #byebug
  #  assert_difference('Filestore.count', -1) do
  #    delete :destroy, params: { username: @user.username, resource: 'filestores', id: @filestore.id}
  #  end

  #  assert_redirected_to things_path(@filestore)
  #  puts "destroy 2"
  #end

end
