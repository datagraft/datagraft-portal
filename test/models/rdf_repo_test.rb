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
    @testRdfRepoUrl = nil  # Assign this when creating external repository
  end

  teardown do
    puts "Do teardown ..."

    # Cleanup using the url from the test object

    delete_test_dbm_s4_repository(@testDbmS4, @testRdfRepoUrl)
    # When controller is using cache it may be a good idea to reset it afterwards
    Rails.cache.clear

  end

  test "create private repo success path" do

    # Remember number of objects for later testing
    se_count_before = SparqlEndpoint.count
    rr_count_before = RdfRepo.count

    create_an_external_repository(false) # Make private repo
    upload_file()

    # Check that we have more objects
    se_count_after = SparqlEndpoint.count
    rr_count_after = RdfRepo.count
    assert se_count_after == (se_count_before+1), "SparqlEndpoint count not increased by one"
    assert rr_count_after == (rr_count_before+1), "RdfRepo count not increased by one"

    # Test that repo is private
    assert @testRdfRepo.is_public == false, "Repository should be private"
    assert_raises(StandardError) do
      size = @testRdfRepo.read_size_wo_key_for_test() # Read without key shall fail
    end

    # Test reading from private repo
    do_a_query()

    # Make repo public
    @testRdfRepo.update_repository_public(true)
    assert @testRdfRepo.is_public == true, "Repository should be public"
    wait_for_repo_to_become_public()  # This can take time...

    # Test public repo
    size = @testRdfRepo.read_size_wo_key_for_test()
    assert size > 0, "Size in repo should be more than 0"
    # Test reading from public repo
    do_a_query()

    # Delete the repo
    delete_external_repository_and_local_objects

    # Check that the objects are removed
    se_count_end = SparqlEndpoint.count
    rr_count_end = RdfRepo.count
    assert se_count_end == se_count_before, "SparqlEndpoint count not same as start "
    assert rr_count_end == rr_count_before, "RdfRepo count not same as start"

  end


  test "create public repo success path" do

    # Remember number of objects for later testing
    se_count_before = SparqlEndpoint.count
    rr_count_before = RdfRepo.count

    create_an_external_repository(true) # Make public repo
    assert @testRdfRepo.is_public == true, "Repository should be public"
    upload_file()

    # Check that we have more objects
    se_count_after = SparqlEndpoint.count
    rr_count_after = RdfRepo.count
    assert se_count_after == (se_count_before+1), "SparqlEndpoint count not increased by one"
    assert rr_count_after == (rr_count_before+1), "RdfRepo count not increased by one"

    wait_for_repo_to_become_public  # This can take time...

    # Test public repo
    size = @testRdfRepo.read_size_wo_key_for_test()
    assert size > 0, "Size in repo should be more than 0"
    # Test reading from public repo
    do_a_query()

    # Delete the repo
    delete_external_repository_and_local_objects

    # Check that the objects are removed
    se_count_end = SparqlEndpoint.count
    rr_count_end = RdfRepo.count
    assert se_count_end == se_count_before, "SparqlEndpoint count not same as start "
    assert rr_count_end == rr_count_before, "RdfRepo count not same as start"

  end

  test "create private repo key problems" do

    # Remember number of objects for later testing
    se_count_before = SparqlEndpoint.count
    rr_count_before = RdfRepo.count

    # Disable the key
    @testKey.enabled = false
    @testKey.save

    assert_raises(StandardError) do
      create_an_external_repository(false) # Create without key shall fail
    end

    # Delete the repo
    delete_external_repository_and_local_objects

    # Wrong key
    @testKey.enabled = true
    @testKey.key_pub = 'xxx'
    @testKey.key_secret = 'yyy'
    @testKey.save

    assert_raises(StandardError) do
      create_an_external_repository(false) # Create without key shall fail
    end

    # Delete the repo
    delete_external_repository_and_local_objects

    # Missing key
    @testKey.destroy

    assert_raises(StandardError) do
      create_an_external_repository(false) # Create without key shall fail
    end

    # Delete the repo
    delete_external_repository_and_local_objects

    # Check that the objects are removed
    se_count_end = SparqlEndpoint.count
    rr_count_end = RdfRepo.count
    assert se_count_end == se_count_before, "SparqlEndpoint count not same as start "
    assert rr_count_end == rr_count_before, "RdfRepo count not same as start"

  end

  test "create private repo dbm problems" do

    # Remember number of objects for later testing
    se_count_before = SparqlEndpoint.count
    rr_count_before = RdfRepo.count


    # Wrong endpoint
    tmp_endpoint = @testDbmS4.endpoint
    @testDbmS4.endpoint = @testDbmS4.endpoint + "xyz"
    @testDbmS4.save

    assert_raises(StandardError) do
      create_an_external_repository(false) # Create without correct dbm shall fail
    end

    # Delete the repo
    delete_external_repository_and_local_objects

    # Missing endpoint
    @testDbmS4.endpoint = ""
    @testDbmS4.save

    assert_raises(StandardError) do
      create_an_external_repository(false) # Create without correct dbm shall fail
    end

    # Delete the repo
    delete_external_repository_and_local_objects

    # Missing dbm
    tmp_dbm = @testDbmS4
    @testDbmS4 = nil

    assert_raises(StandardError) do
      create_an_external_repository(false) # Create without correct dbm shall fail
    end

    # Delete the repo
    delete_external_repository_and_local_objects

    # Restore dbm record
    @testDbmS4 = tmp_dbm
    @testDbmS4.endpoint = tmp_endpoint

    # Check that the objects are removed
    se_count_end = SparqlEndpoint.count
    rr_count_end = RdfRepo.count
    assert se_count_end == se_count_before, "SparqlEndpoint count not same as start "
    assert rr_count_end == rr_count_before, "RdfRepo count not same as start"

  end

  test "access existing repo with key dbm or url problems" do

    # Remember number of objects for later testing
    se_count_before = SparqlEndpoint.count
    rr_count_before = RdfRepo.count

    create_an_external_repository(false) # Make private repo
    assert @testRdfRepo.is_public == false, "Repository should be private"
    upload_file()

    # Disable the key
    @testKey.enabled = false
    @testKey.save

    assert_raises(StandardError) do
      upload_file()
    end
    assert_raises(StandardError) do
      do_a_query()
    end
    assert_raises(StandardError) do
      @testSparqlEndpoint.rdf_repo.destroy
    end
    assert_raises(StandardError) do
      @testRdfRepo.update_repository_public(false)
    end

    # Wrong key
    @testKey.enabled = true
    tmp_pub = @testKey.key_pub
    tmp_secret = @testKey.key_secret
    @testKey.key_pub = 'xxx'
    @testKey.key_secret = 'yyy'
    @testKey.save

    assert_raises(StandardError) do
      upload_file()
    end
    assert_raises(StandardError) do
      do_a_query()
    end
    assert_raises(StandardError) do
      @testSparqlEndpoint.rdf_repo.destroy
    end
    assert_raises(StandardError) do
      @testRdfRepo.update_repository_public(false)
    end

    # Restore key
    @testKey.key_pub = tmp_pub
    @testKey.key_secret = tmp_secret
    @testKey.save

    # Verify restored key
    upload_file()
    do_a_query()
    @testRdfRepo.update_repository_public(false)

    # Wrong uri
    tmp_uri = @testRdfRepo.uri
    @testRdfRepo.uri = @testRdfRepo.uri + "xyz"
    @testRdfRepo.save

    assert_raises(StandardError) do
      upload_file()
    end
    assert_raises(StandardError) do
      do_a_query()
    end
    assert_raises(StandardError) do
      @testSparqlEndpoint.rdf_repo.destroy
    end
    #assert_raises(StandardError) do    TODO This one does not result in raise
    #  @testRdfRepo.update_repository_public(false)
    #end

    # Missing uri
    @testRdfRepo.uri = ""
    @testRdfRepo.save

    assert_raises(StandardError) do
      upload_file()
    end
    assert_raises(StandardError) do
      do_a_query()
    end
    assert_raises(StandardError) do
      @testSparqlEndpoint.rdf_repo.destroy
    end
    assert_raises(StandardError) do
      @testRdfRepo.update_repository_public(false)
    end

    # Restore uri
    @testRdfRepo.uri = tmp_uri
    @testRdfRepo.save

    # Verify restored uri
    upload_file()
    do_a_query()
    @testRdfRepo.update_repository_public(false)

    # Missing dbm
    tmp_dbm = @testRdfRepo.dbm
    @testRdfRepo.dbm = nil
    @testRdfRepo.save
    assert_raises(StandardError) do
      @testSparqlEndpoint.rdf_repo.destroy
    end
    assert_raises(StandardError) do
      @testRdfRepo.update_repository_public(false)
    end

    # Restore dbm
    @testRdfRepo.dbm = tmp_dbm
    @testRdfRepo.save

    # Verify restored dbm
    upload_file()
    do_a_query()
    @testRdfRepo.update_repository_public(false)

    # Delete the repo
    delete_external_repository_and_local_objects

    # Check that the objects are removed
    se_count_end = SparqlEndpoint.count
    rr_count_end = RdfRepo.count
    assert se_count_end == se_count_before, "SparqlEndpoint count not same as start "
    assert rr_count_end == rr_count_before, "RdfRepo count not same as start"

  end


  ########################
  private
  ########################

  def create_an_external_repository(pub)

    # Create sparql endpoint model
    @testSparqlEndpoint = create_test_sparql_endpoint(@testUser)
    @testSparqlEndpoint.public = pub

    # Create rdf repo model
    @testRdfRepo = RdfRepo.new
    @testRdfRepo.dbm = @testDbmS4
    @testRdfRepo.name = "RR:TestRdfRepo"
    @testRdfRepo.save
    @testSparqlEndpoint.rdf_repo = @testRdfRepo

    # Create external repository
    @testRdfRepo.create_repository(@testSparqlEndpoint)
    @testRdfRepoUrl = @testRdfRepo.uri  # Save url in case of cleanup
    @testRdfRepo.save
    @testSparqlEndpoint.save

    # Feed the sparql endpoint state machine (fake events just to get out uri)
    @testSparqlEndpoint.issue_create_repo
    @testSparqlEndpoint.repo_successfully_created

    assert @testRdfRepo.uri != nil, "URI is not set"
    assert @testRdfRepo.uri == @testSparqlEndpoint.uri, "URI is not set for both RdfRepo and SparqlEndpoint"
    assert @testRdfRepo.name == "RR:TestRdfRepo", "Name not correctly stored"
    assert @testSparqlEndpoint.has_rdf_repo? == true, "SparqlEndpoint should have RdfRepo"
  end

  def upload_file

    size_before = @testSparqlEndpoint.rdf_repo.get_repository_size()

    # Upload file to external repository
    rdf_file = file_fixture("simpsons.nt")
    rdf_type = 'nt'
    @testSparqlEndpoint.rdf_repo.upload_file_to_repository(rdf_file, rdf_type)

    size_after = @testSparqlEndpoint.rdf_repo.get_repository_size()
    assert size_after > size_before, "RdfRepo size not changed after upload"
    assert size_after == @testSparqlEndpoint.rdf_repo.cached_size, "RdfRepo size not cached"
  end

  def wait_for_repo_to_become_public
    retries = 60
    is_public_now = false
    puts "Waiting for repo to become public up to #{retries} seconds"
    while retries > 0 and !is_public_now do
      begin
        sleep(1)  # Wait some time so database is public
        size = @testRdfRepo.read_size_wo_key_for_test()
        is_public_now = true
      rescue
        retries -= 1
      end
    end
    puts "Ended wait after #{60-retries} seconds"
    assert is_public_now == true, "Timeout waiting for external repo becomming public"
  end

  def do_a_query
    # Test to query
    res = @testRdfRepo.query_repository("select * where { ?s ?p ?o .} limit 10")
    query_res = JSON.parse(res)
    assert query_res['head']['vars'] == ["s", "p", "o"], "Unexpected query result"
  end

  def delete_external_repository_and_local_objects

    # Delete rdf repo and sparql endpoint
    rr = @testSparqlEndpoint.rdf_repo
    rr.destroy
    @testSparqlEndpoint.destroy
  end

end
