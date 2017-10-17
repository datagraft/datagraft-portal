ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

# module to help with sign-ins
module SignInHelper
  # creates a new user for testing purposes
  def create_test_user_if_not_exists
    if not user = User.find_by_username('datagraft_test_user')
      user = User.new({:username => "datagraft_test_user", :name => "tester",:email => "test@test.testtest", :password => "test1234", :password_confirmation => "test1234", :terms_of_service => true}) unless user = User.find_by_username('datagraft_test_user')
      user.save(:validate => false)
    end

    return user
  end
end

#module to help creating a DbmXXX setup for testing of interaction with RdfRepos and SparqlEndpoints
module DbmXXXHelper
  def create_test_dbm_s4(testUser)
    testDbmS4 = DbmS4.new()
    testDbmS4.user = testUser
    testDbmS4.name = 'TestDbmS4'
    testDbmS4.endpoint = ENV['DBMS4_EP']
    testDbmS4.db_plan = "BL1"
    testDbmS4.save

    return testDbmS4
  end

  def get_test_dbm_s4_key
    return ENV['DBMS4_KEY']
  end

  def get_test_dbm_s4_secret
    return ENV['DBMS4_SECRET']
  end

end

# module to help with one initial filestore obj in the fixture
module FilestoreHelper
  # Uploads a new file if not already there
  def create_test_filestore_if_not_exists
    if Filestore.exists?(name: 'test.xls')
      # Record exists ... nothing to do
      puts "Found test filestore"
    else
      puts "Creating test filestore"
      test_file = fixture_file_upload("/files/test.xls", "application/vnd.ms-excel", :binary)
      post :create, params: { username: @user.username, filestore: { file: test_file }}
    end
    fs = Filestore.where(name: 'test.xls')
    return fs

  end
end

class ActiveSupport::TestCase
    include SignInHelper
    include DbmXXXHelper
    include FilestoreHelper
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end
