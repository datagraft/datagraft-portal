require 'test_helper'

class DbmS4Test < ActiveSupport::TestCase
  setup do
    # Check that db is clean
    keys = ApiKey.all
    assert keys.count == 0, "Old ApiKeys are detected"

    dbms4 = DbmS4.all
    assert dbms4.count == 0, "Old DbmS4 are detected"

    # Create a user for testing
    @testUser = create_test_user_if_not_exists

    @testDbmS4 = create_test_dbm_s4(@testUser)
    #@testKey = @testDbmS4.add_key('TestS4Key', get_test_dbm_s4_key, get_test_dbm_s4_secret, true)

  end

  teardown do
    # When controller is using cache it may be a good idea to reset it afterwards
    Rails.cache.clear

  end


  test "test methods on empty dbm" do
    support_rdf = @testDbmS4.get_supported_repository_types.include? 'RDF'
    assert support_rdf == true , 'DbmS4 should support RDF'

    assert @testDbmS4.used_sparql_count == 0, 'DbmS4 should not have any rdf_repo when created'

    ust = @testDbmS4.used_sparql_triples
    assert ust[:repo_triples] == 0, 'DbmS4 should not have any triples when created'

  end


  test "should not have api_key create one" do
    assert @testDbmS4.api_keys.count == 0, 'DbmS4 should not have any api keys when created'

    # Test that first_enabled_key method is raising an exception
    assert_raises(StandardError) do
      @testDbmS4.first_enabled_key
    end

    # Create a key
    testKey = @testDbmS4.add_key('TestS4Key', get_test_dbm_s4_key, get_test_dbm_s4_secret, true)
    # Read back key
    rdKey = @testDbmS4.first_enabled_key
    # They should be the same
    assert testKey == rdKey, 'DbmS4 key mismatch'

    assert @testDbmS4.allow_manual_api_key? == true, 'DbmS4 should allow manual keys'

    #puts "dbmS4: #{@testDbmS4.inspect}"
    #puts "apiKey: #{@testDbmS4.api_keys.first.inspect}"
    #puts "testUser: #{@testUser.inspect}"
  end



#  test "should delete S4 repository" do
#    assert @testDbmS4.send(:delete_repository("repository1"))
#  end

end
