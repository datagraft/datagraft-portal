require 'test_helper'

class OntotextUserTest < ActiveSupport::TestCase
  setup do
    # Create a user for testing
    @user = create_test_user_if_not_exists
    
    # Set default values for registered ontotext accoubt
#    @user.ontotext_account = 100000003
#    @user.encrypted_password = @user.password
    
    # Create Ontototext test account
    @user.send(:register_ontotext_test_account)
    @user.encrypted_password = @user.password
  end
  
  teardown do
    # When controller is using cache it may be a good idea to reset it afterwards
    Rails.cache.clear
    
    # Delete Ontotext test account
#    connect = @user.ontotext_login
#    @user.delete_ontotext_account(connect)
    @user.delete_ontotext_account
  end

=begin
  test "should create new api connection" do
    assert @user.send(:new_api_connexion)
  end
  
  test "should register ontotext account" do
    # not implemented yet
    # assert @user.send(:register_ontotext_account)
  end
  
  test "should create ontotext connexion" do
    assert @user.send(:ontotext_connexion)
  end
  
  test "should get ontotext api keys" do
    # not implemented yet
    # assert @user.send(:ontotext_api_keys)
  end
=end
  
  test "should get login status authenticated" do
    connect = @user.ontotext_login
    assert_equal('{"status":"AUTHENTICATED"}', @user.get_login_status(connect), msg = nil)
  end

end
