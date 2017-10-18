require 'test_helper'

class RdfRepoTest < ActiveSupport::TestCase
  setup do
    puts "Do setup ..."
    # Check that db is clean
    keys = ApiKey.all
    assert keys.count == 0, "Old ApiKeys are detected"

    dbms4 = DbmS4.all
    assert dbms4.count == 0, "Old DbmS4 are detected"

    # Create a user for testing
    @testUser = create_test_user_if_not_exists

    @testDbmS4 = create_test_dbm_s4(@testUser)
    @testKey = @testDbmS4.add_key('TestS4Key', get_test_dbm_s4_key, get_test_dbm_s4_secret, true)

  end

  teardown do
    puts "Do teardown ..."
    delete_test_dbm_s4_repository(@testDbmS4)
    # When controller is using cache it may be a good idea to reset it afterwards
    Rails.cache.clear

  end

  test "create repo success path" do

    se_count_before = SparqlEndpoint.count
    rr_count_before = RdfRepo.count

    # Create sparql endpoint model
    se = create_test_sparql_endpoint(@testUser)

    # Create rdf repo model
    rr = RdfRepo.new
    rr.dbm = @testDbmS4
    rr.name = "RR:TestRdfRepo"
    rr.save
    se.rdf_repo = rr

    # Create external repository
    rr.create_repository(se)
    rr.save
    se.save

    # Feed the sparql endpoint state machine (fake events just to get out uri)
    se.issue_create_repo
    se.repo_successfully_created

    assert rr.uri != nil, "URI is not set"
    assert rr.uri == se.uri, "URI is not set for both RdfRepo and SparqlEndpoint"

    size_before = se.rdf_repo.get_repository_size()

    # Upload file to external repository
    rdf_file = file_fixture("simpsons.nt")
    rdf_type = 'nt'
    se.rdf_repo.upload_file_to_repository(rdf_file, rdf_type)

    size_after = se.rdf_repo.get_repository_size()

    se_count_after = SparqlEndpoint.count
    rr_count_after = RdfRepo.count
    assert se_count_after == (se_count_before+1), "SparqlEndpoint count not increased by one"
    assert rr_count_after == (rr_count_before+1), "RdfRepo count not increased by one"
    assert size_after > size_before, "RdfRepo size not changed after upload"

    assert se.has_rdf_repo? == true, "SparqlEndpoint should have RdfRepo"

    # Delete rdf repo and sparql endpoint
    rr = se.rdf_repo
    rr.destroy
    se.destroy

    se_count_end = SparqlEndpoint.count
    rr_count_end = RdfRepo.count
    assert se_count_end == se_count_before, "SparqlEndpoint count not same as start "
    assert rr_count_end == rr_count_before, "RdfRepo count not same as start"

    puts "SparqlEndpoints count: #{SparqlEndpoint.count}"
    puts "RdfRepo count: #{RdfRepo.count}"

  end

end
