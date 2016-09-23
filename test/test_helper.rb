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

# module to help with one initial filestore obj in the fixture
module FilestoreHelper
  # Uploads a new file if not already there
  def create_test_filestore_if_not_exists
    byebug
    if Filestore.exists?('test.xls')
      # Record exists ... nothing to do
    else
      test_file = fixture_file_upload("/files/test.xls", "application/vnd.ms-excel", :binary)
      post :create, params: {:controller => "filestores", :filestore => 'dummy', :username => @user.username, :file => test_file }
    end

  end
end

class ActiveSupport::TestCase
    include SignInHelper
    include FilestoreHelper
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end
