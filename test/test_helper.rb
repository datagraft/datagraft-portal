ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

# module to help with sign-ins
module TestSignInHelper
  # creates a new user for testing purposes
  def create_test_user_if_not_exists
    if not user = User.find_by_username('datagraft_test_user')
      user = User.new({:username => "datagraft_test_user", :name => "tester",:email => "test@test.testtest", :password => "test1234", :password_confirmation => "test1234", :terms_of_service => true}) unless user = User.find_by_username('datagraft_test_user')
      user.save(:validate => false)
    end
    # puts "*************** create_test_user_if_not_exists():  #{User.find_by_username('datagraft_test_user').inspect} ***************"
    return user
  end
end

#module to help creating a DbmS4 setup for testing of interaction with RdfRepos and SparqlEndpoints
module TestDbmS4Helper
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

  def delete_test_dbm_s4_repository(dbms4, url)
    puts "***** Clean up DbmS4 repository"

    if url.nil?
      puts "No clean up of DbmS4 repository URL==nil"
      return
    end

    begin
      #api_key = dbms4.first_enabled_key
      #basicToken = Base64.strict_encode64(api_key.key)
      basicToken = Base64.strict_encode64("#{get_test_dbm_s4_key}:#{get_test_dbm_s4_secret}")

      request = RestClient::Request.new(
        :method => :delete,
        :url => url,
        :headers => {
          'Authorization' => 'Basic ' + basicToken,
          'Content-Type' => 'application/json'
        }
      )

      puts request.inspect
      response = request.execute
      puts "Clean up DbmS4 repository with response code #{response.code}"
    rescue => e
      puts "Clean up DbmS4 repository with ex #{e.message}"
    end

  end

end

#module to help creating a DbmArango setup for testing of interaction with ArangoDb asset
module TestDbmArangoHelper
  def create_test_dbm_arango(testUser)
    testDbmArango = DbmArango.new()
    testDbmArango.user = testUser
    testDbmArango.name = 'TestDbmArango'
    testDbmArango.uri = get_test_dbm_arango_db_uri
    testDbmArango.save

    return testDbmArango
  end

  def get_test_dbm_arango_db_uri
    return ENV['DBMARANGO_URI']
  end

  def get_test_dbm_arango_db_name
    return ENV['DBMARANGO_DBNAME']
  end

  def get_test_dbm_arango_rw_user
    return ENV['DBMARANGO_RW_USER']
  end

  def get_test_dbm_arango_rw_pwd
    return ENV['DBMARANGO_RW_PWD']
  end

  def get_test_dbm_arango_ro_user
    return ENV['DBMARANGO_RO_USER']
  end

  def get_test_dbm_arango_ro_pwd
    return ENV['DBMARANGO_RO_PWD']
  end

  def delete_test_dbm_arango_collections(dbmarango, db_name)
    puts "***** Clean up DbmArango collections"

    if db_name.nil?
      puts "No clean up of DbmArango collections dbm_name==nil"
      return
    end

    begin
      count = 0
      coll_arr = dbmarango.get_collections(db_name, false)
      coll_arr.each do |coll|
        puts "  COL: #{coll[:name]} #{coll[:type]}"
        info = dbmarango.delete_collection(coll, false)
        count += 1
      end
      puts "Clean up DbmArango #{count} collections"
    rescue => e
      puts "Clean up DbmArango #{count} collections with ex #{e.message}"
    end

  end

end

#module to help creating a SparqlEndpoint for testing
module TestSparqlEndpointHelper
  def create_test_sparql_endpoint(testUser)
    se = SparqlEndpoint.new()
    se.user = testUser
    se.name = "TestName"
    se.description = "TestDescription"
    se.slug = "TestSlug"
    se.save

    return se
  end
end

# module to help with one initial filestore obj in the fixture
module TestFilestoreHelper
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
    include TestSignInHelper
    include TestDbmS4Helper
    include TestDbmArangoHelper
    include TestSparqlEndpointHelper
    include TestFilestoreHelper
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end
