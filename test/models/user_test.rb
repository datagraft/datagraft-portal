require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    # Create a user for testing
    @user = create_test_user_if_not_exists
  end

  def create_autodel_user_if_not_exists
    if not user = User.find_by_username('test_auto_delete')
      user = User.new({:username => "test_auto_delete", :name => "autodeltest",:email => "autodeltest@test.testtest", :password => "test1234", :password_confirmation => "test1234", :terms_of_service => true}) unless user = User.find_by_username('test_auto_delete')
      user.save(:validate => false)
    end

    return user
  end

  test "test auto delete of user assets" do
    # Create a new test user that will be deleted later
    initial_user_count = User.all.count
    puts 'Initial user count:' + initial_user_count.to_s
    new_test_user = create_autodel_user_if_not_exists

    #Check that we got one more user
    assert((initial_user_count+1) == User.all.count, "Error autodel user not created")

    # Create a new filestore
    initial_filestore_count = Filestore.all.count
    puts 'Initial filestore count:' + initial_filestore_count.to_s
    new_filestore = Filestore.new
    new_filestore.user = new_test_user
    new_filestore.name = 'new_fs'
    puts new_filestore.save!

    #Check that we got one more filestore
    assert((initial_filestore_count+1) == Filestore.all.count, "Error filestore not created")

    # Create a new sparql_endpoint owned by default @user (shall not be not deleted)
    initial_sparql_count = SparqlEndpoint.all.count
    puts 'Initial sparql_endpoint count:' + initial_sparql_count.to_s
    new_sparql = SparqlEndpoint.new
    new_sparql.user = @user
    new_sparql.name = 'new_sparql'
    puts new_sparql.save!

    # Check that we got one more sparql_endpoint
    assert((initial_sparql_count+1) == SparqlEndpoint.all.count, "Error sparql_endpoint not created")


    # Create a new query
    initial_query_count = Query.all.count
    puts 'Initial query count:' + initial_query_count.to_s
    new_query = Query.new
    new_query.user = new_test_user
    new_query.name = 'new_query'
    new_query.query = 'xxx'
    puts new_query.save!

    #Check that we got one more query
    assert((initial_query_count+1) == Query.all.count, "Error query not created")

    # Create a relation between query and sparql
    initial_seq_count = SparqlEndpointQuery.all.count
    puts 'Initial SparqlEndpointQueries count:' + initial_seq_count.to_s
    #puts 'q.s 1 ' + new_query.sparql_endpoints.find(new_sparql.id)
    new_query.sparql_endpoints << new_sparql
    puts new_query.save!

    # Check thta we got one more relation
    assert((initial_seq_count+1) == SparqlEndpointQuery.all.count, "Error relation 1 not created")

    # Create a relation between sparql and query
    new_sparql.queries << new_query
    puts new_sparql.save!

    #Check that we got a second relation
    assert((initial_seq_count+2) == SparqlEndpointQuery.all.count, "Error relation 2 not created")


    # Delete the new_test_user
    new_test_user.destroy
    assert(initial_user_count == User.all.count, "Error autodel user not deleted")
    # Check that the filestore connected to the new_test_user is deleted
    assert(initial_filestore_count == Filestore.all.count, "Error filestore asset not deleted")
    # Check that the sparql_endpoint connected to the default @user remains
    assert((initial_sparql_count+1) == SparqlEndpoint.all.count, "Error sparql_endpoint deleted by wrong user")
    # Check that the query connected to the new_test_user is deleted
    assert(initial_query_count == Query.all.count, "Error query asset not deleted")
    # Check that the relations connected to the new_test_user assets is deleted
    assert(initial_seq_count == SparqlEndpointQuery.all.count, "Error relation not deleted")

    # Delete the user owned by default @user
    new_sparql.destroy
    # Check that the sparql_endpoint connected to the default @user is deleted
    assert(initial_sparql_count == SparqlEndpoint.all.count, "Error sparql_endpoint asset not deleted")
  end

end
