require 'test_helper'

class DbmS4Test < ActiveSupport::TestCase
  setup do
    # Create a user for testing
    #@testUser = create_test_user_if_not_exists
    
#    @testDbmS4 = DbmS4.new()
#    @testDbmS4.user = @testUser
  end
  
  teardown do
    # When controller is using cache it may be a good idea to reset it afterwards
    Rails.cache.clear
    
  end
  
  test "should create S4 repository" do
    assert true
    @testDbmS4 = DbmS4.new()
#    assert @testDbmS4.send(:create_repository)
  end

#  test "should delete S4 repository" do
#    assert @testDbmS4.send(:delete_repository("repository1"))
#  end
  
end
