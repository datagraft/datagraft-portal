require 'test_helper'

class DbmAccountsControllerTest < ActionController::TestCase
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
      dbm_id: @testDbmArango.id,
      resource: 'dbm_accounts'
    }
    assert_response :success
    assert_not_nil assigns(:dbm_accounts)
  end

  # GET /dbms/:dbm_id/:resource/new
  test "should get new dbm_account" do
    get :new, params: {
      username: @user.username,
      dbm_id: @testDbmArango.id,
      resource: 'dbm_accounts'
    }
    assert_response :success
  end

  # POST /dbms/:dbm_id/:resource
  test "should create dbm_account" do
    assert_difference('DbmAccount.count') do

      post :create, params: {
        username: @user.username,
        resource: 'dbm_accounts',
        dbm_id: @testDbmArango.id,
        dbm_account: {
          name: get_test_dbm_arango_rw_user,
          password: get_test_dbm_arango_rw_pwd,
          enabled: false,
          public: true
        }
      }
    end
    assert_redirected_to dbm_dbm_accounts_path(assigns(:dbm))

  end

  # GET /dbms/:dbm_id/:resource/:id
  test "should show dbm_account" do
    get :show, params: {
      username: @user.username,
      resource: 'dbm_accounts',
      dbm_id: @testDbmArango.id,
      id: @testAccountRw.id
    }
    assert_redirected_to dbm_dbm_accounts_path(assigns(:dbm))
  end

  # GET /dbms/:dbm_id/:resource/:id/edit
  test "should get edit dbm_account" do
    get :edit, params: {
      username: @user.username,
      resource: 'dbm_accounts',
      dbm_id: @testDbmArango.id,
      id: @testAccountRw.id
    }
    assert_response :success
  end

  # PATH/PUT /dbms/:dbm_id/:resource/:id
  test "should update dbm_account" do
    patch :update, params: {
      username: @user.username,
      resource: 'dbm_accounts',
      dbm_id: @testDbmArango.id,
      id: @testAccountRw.id,
      dbm_account: {
          name: get_test_dbm_arango_ro_user,
          password: get_test_dbm_arango_ro_pwd,
          enabled: false,
          public: true
      }
    }
    assert_redirected_to dbm_dbm_accounts_path(assigns(:dbm))
  end

  # DELETE /dbms/:dbm_id/:resource/:id
  test "should delete dbm_account" do
    assert_difference('DbmAccount.count', -1) do
      delete :destroy, params: {
        username: @user.username,
        resource: 'dbm_accounts',
        dbm_id: @testDbmArango.id,
        id: @testAccountRw.id
      }
    end
    assert_redirected_to dbm_dbm_accounts_path(assigns(:dbm))
  end

  private

end
