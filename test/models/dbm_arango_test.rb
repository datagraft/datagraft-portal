require 'test_helper'

class DbmArangoTest < ActiveSupport::TestCase
  setup do
    # Check that db is clean
    accounts = DbmAccount.all
    assert accounts.count == 0, "Old DbmAccounts are detected"

    dbmarango = DbmArango.all
    assert dbmarango.count == 0, "Old DbmArango are detected"

    # Create a user for testing
    @testUser = create_test_user_if_not_exists

    @testDbmArango = create_test_dbm_arango(@testUser)

  end

  teardown do
    # When controller is using cache it may be a good idea to reset it afterwards
    Rails.cache.clear

  end


  test "test methods on empty dbm" do
    support = @testDbmArango.get_supported_repository_types.include? 'ARANGO'
    assert support == true , 'DbmArango should support ARANGO'

  end


  test "should not have dbm_account create one" do
    assert @testDbmArango.dbm_accounts.count == 0, 'DbmArango should not have any accounts when created'

    # Test that first_enabled_key method is raising an exception
    assert_raises(StandardError) do
      @testDbmArango.first_enabled_account(false)
    end

    # Create an account
    testAccount = @testDbmArango.add_account(get_test_dbm_arango_rw_user, get_test_dbm_arango_rw_pwd, true)
    # Read back account
    rdAccount = @testDbmArango.first_enabled_account(false)
    # They should be the same
    assert testAccount == rdAccount, 'DbmArango account mismatch'

    #puts "dbmArango: #{@testDbmArango.inspect}"
    puts "dbmAccount: #{@testDbmArango.dbm_accounts.first.inspect}"
    #puts "testUser: #{@testUser.inspect}"
  end



#  test "should delete S4 repository" do
#    assert @testDbmS4.send(:delete_repository("repository1"))
#  end

end
