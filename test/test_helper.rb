ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

# module to help with sign-ins
module SignInHelper
  # creates a new user for testing purposes
  def create_test_user_if_not_exists
    if not user = User.find_by_username('test_user')
      user = User.new({:username => "test_user", :name => "tester",:email => "test@test.testtest", :password => "test", :password_confirmation => "test", :terms_of_service => true}) unless user = User.find_by_username('test_user')
      user.save(:validate => false) 
    end
    
    return user
  end
end

class ActiveSupport::TestCase
  include SignInHelper
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  
  # Add more helper methods to be used by all tests here...
end
