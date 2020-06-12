require 'rest-client'

class DbmGraphdb < Dbm
  
  # Non-persistent attribute for storing inputs from new form
  attr_accessor :dbm_account_username
  attr_accessor :dbm_account_password


  ######
  public
  ######

  def get_supported_repository_types
    return %w(RDF)
  end

  def get_supported_db_plans
    return %w(EE SE Free)
  end

  def db_plan
    configuration["db_plan"] if configuration
  end

  def db_plan=(val)
    touch_configuration!
    configuration["db_plan"] = val
  end

  def endpoint
    configuration["endpoint"] if configuration
  end

  def endpoint=(val)
    touch_configuration!
    configuration["endpoint"] = val
  end

  def find_things
    se = []
    self.rdf_repos.each do |rr|
      rr.things.each do |thing|
        se << thing
      end
    end
    return se
  end
  
  def get_authorization_token
    da = first_enabled_account_ignore_public
    basicToken = Base64.strict_encode64(da.name + ':' + da.password)
    return basicToken
  end

  
  # Create GraphDB repository
  def create_repository(rdf_repo, ep)
    puts "***** Enter DbmGraphdb.create_repository(#{name})"

    url = rdf_repo.dbm.endpoint + '/rest/repositories'
    basicToken = self.get_authorization_token
    
    type = case self.db_plan
    when 'Free' then
      'free'
    else
      'worker'
    end

    request = RestClient::Request.new(
      :method => :put,
      :url => url,
      :payload => {
        'id' => ep.slug,
        'location' => '',
        'missingDefaults' => {},
        'params' => {},
        'sesameType' => 'openrdf:SystemRepository',
        'title' => '',
        'type' => type
      }.to_json,
      :headers => {
        'Authorization' => 'Basic ' + basicToken,
        'Content-Type' => 'application/json'
      }
    )

    puts request.inspect
    response = request.execute
    raise "Error creating new repository" unless response.code.between?(200, 299)

    rdf_repo.repo_hash = {repo_id: "DbmGraphdb repo_id #{type}:#{name}:#{rdf_repo.name}" }
    rdf_repo.is_public = ep.public
    
    rdf_repo.uri = rdf_repo.dbm.endpoint + '/repositories/' + ep.slug
    ep.uri = rdf_repo.uri

    # By default all newly created GraphDB repositories are private
    # and only accessible by user accounts. 
    # When a repository is set to public we enable the free user access in GraphDB.
    if rdf_repo.is_public
      update_repository_public(rdf_repo, rdf_repo.is_public)
    end

    puts "***** Exit DbmGraphdb.create_repository()"
  end


  # Update GraphDB repository public property
  def update_repository_public(rdf_repo, public)
    puts "***** Enter DbmGraphdb.set_repository_public(#{name})"

    url = "http://businessgraph.ontotext.com/rest/security/freeaccess"
    da = first_enabled_account_ignore_public
    basicToken = Base64.strict_encode64(da.name + ':' + da.password)
    
    rr_stripped_name = rdf_repo.name.gsub("RR:", '')

    request = RestClient::Request.new(
      :method => :post,
      :url => url,
      :payload => {
        'enabled' => public.to_s,
        'authorities' => ["ROLE_USER", "READ_REPO_*_" + rr_stripped_name]
      }.to_json,
      :headers => {
        'Authorization' => 'Basic' + ' ' + basicToken,
        'Content-Type' => 'application/json'
      }
    )
    
    puts request.inspect
    response = request.execute
    raise "Error updating GraphDB repository public property" unless response.code.between?(200, 299)

    rdf_repo.is_public = public
    rdf_repo.save

    puts "***** Exit DbmGraphdb.set_repository_public()"
  end
  

  def used_sparql_count
    rdf_repo_list = self.rdf_repos.all #TODO fix to count real sparql_endpoints
    return rdf_repo_list.size
  end


  def used_sparql_triples
    puts "***** Enter DbmGraphdb.quota_used_sparql_triples(#{name})"
    total_repo_sparql_triples = 0
    total_cached_sparql_triples = 0
    cached_sparql_requests = 0

    rdf_repo_list = self.rdf_repos.all
    rdf_repo_list.each do |rr|
      total_repo_sparql_triples += rr.get_repository_size
    end
    res = {repo_triples: total_repo_sparql_triples, cached_triples: total_cached_sparql_triples, cached_req: cached_sparql_requests}
    puts "***** Exit DbmGraphdb.quota_used_sparql_triples()"
    return res
  end


  # Get GraphDB database quota count for max repositories
  def quota_sparql_count()
    puts "***** Enter DbmGraphdb.quota_sparql_count(#{name})"

    res = case self.db_plan
    when 'EE' then
      1000
    when 'SE' then
      10
    when 'Free' then
      1
    else
      1
    end

    puts "***** Exit DbmGraphdb.quota_sparql_count()"
    return res
  end


  # Get GraphDB database quota count for max triples
  def quota_sparql_ktriples()
    puts "***** Enter DbmGraphdb.quota_sparql_ktriples(#{name})"

    res = case self.db_plan
    when 'EE' then
      1000000000
    when 'SE' then
      10000000
    when 'Free' then
      100000
    else
      100000
    end

    puts "***** Exit DbmGraphdb.quota_sparql_ktriples()"
    return res/1024.0
  end


  # Delete GraphDB repository
  def delete_repository(rdf_repo)
    puts "***** Enter DbmGraphdb.delete_repository(#{name})"

    url = rdf_repo.uri.to_s.gsub("RR:", "")
    basicToken = self.get_authorization_token

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
    raise "Error deleting GraphDB repository" unless response.code.between?(200, 299)

    rdf_repo.repo_hash = {repo_id: 'deleted' }
    rdf_repo.uri = 'Deleted URI...'

    puts "***** Exit DbmGraphdb.delete_repository()"
  end


  # Test user account
  def test_user(user, password)
    puts "***** Enter DbmGraphdb.test_user(#{name})"
#    graphdb_test_user(user, password)

    puts "***** Exit DbmGraphdb.test_user()"
    return true
  end
  
  
  #######
  private
  #######
  
  # Delete all RDF repositories owned by this dbm called by before_destroy
  def unreg_before_destroy()
    puts "***** Enter DbmGraphdb.unreg_before_destroy(#{name})"
    # Remove all rdf_repos referencing this dbm
    # TODO: Pls explain why this is needed?????
    rdf_repos.all.each do |rr|
      rr.destroy
    end

    puts "***** Exit DbmGraphdb.unreg_before_destroy()"
  end
  
end
