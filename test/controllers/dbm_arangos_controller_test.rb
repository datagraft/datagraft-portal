require 'test_helper'

class DbmArangosControllerTest < ActionController::TestCase
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

  end

  teardown do
    puts "Do teardown ..."

    # When controller is using cache it may be a good idea to reset it afterwards
    Rails.cache.clear

  end


  test "should get index" do
    get :index, params: {
      username: @user.username,
      resource: 'dbm_arangos'
    }
    assert_response :success
    assert_not_nil assigns(:dbm_arangos)
  end

  # GET /:resource/new
  test "should get new dbm_arango" do
    get :new, params: {
      username: @user.username,
      resource: 'dbm_arangos'
    }
    assert_response :success
  end

  # POST /:resource/
  test "should create dbm_arango with account" do
    assert_difference('DbmArango.count') do
      assert_difference('DbmAccount.count') do

        post :create, params: {
          username: @user.username,
          resource: 'dbm_arangos',
          dbm_arango: {
            name: "My_test",
            uri: get_test_dbm_arango_db_uri,
            dbm_account_username: get_test_dbm_arango_rw_user,
            dbm_account_password: get_test_dbm_arango_rw_pwd
          }
        }
      end
    end
    assert_redirected_to dbms_path

  end

  # GET /:resource/:id
  test "should show dbm_arango" do
    get :show, params: {
      username: @user.username,
      resource: 'dbm_arangos',
      id: @testDbmArango.id
    }
    assert_redirected_to dbms_path
  end

  # GET /:resource/:id/edit
  test "should get edit dbm_arango" do
    get :edit, params: {
      username: @user.username,
      resource: 'dbm_arangos',
      id: @testDbmArango.id
    }
    assert_response :success
  end

  # PATH/PUT /:resource/:id
  test "should update dbm_arango" do
    patch :update, params: {
      username: @user.username,
      resource: 'dbm_arangos',
      id: @testDbmArango.id,
      dbm_arango: {
        name: 'Blabla',
      }
    }
    assert_redirected_to dbms_path
  end

  # DELETE /:resource/:id
  test "should delete dbm_arango" do
    assert_difference('DbmArango.count', -1) do
      assert_difference('DbmAccount.count', -2) do
        delete :destroy, params: {
          username: @user.username,
          resource: 'dbm_arangos',
          id: @testDbmArango.id
        }
      end
    end
    assert_redirected_to dbms_path
  end

  private

end
