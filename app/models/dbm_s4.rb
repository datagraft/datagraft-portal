require 'rest-client'

class DbmS4 < Dbm

  # Non-persistent attribute for storing inputs from new form
  attr_accessor :dbm_account_username
  attr_accessor :dbm_account_password
  attr_accessor :key
  attr_accessor :secret


  #######
  private
  #######

  # Rails 4 strong params usage
  def dbm_s4_params
    params.require(:dbm_s4).permit(:public, :dbm_account_username, :dbm_account_password, :name, :db_plan, :endpoint, :key, :secret)
  end

  ######
  public
  ######

  @@supported_repository_types = %w(RDF)
  def get_supported_repository_types
    return @@supported_repository_types
  end

  @@supported_db_plans = %w(BL1 BL2 SL1 SL2 EL1 EL2 EL3)
  def get_supported_db_plans
    return @@supported_db_plans
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

  # Create new S4 repository
  def create_repository(rdf_repo, ep)
    puts "***** Enter DbmS4.create_repository(#{name})"

    url = rdf_repo.dbm.endpoint + '/repositories'
    api_key = rdf_repo.dbm.first_enabled_key
    basicToken = Base64.strict_encode64(api_key.key)

    request = RestClient::Request.new(
      :method => :put,
      :url => url,
      :payload => {
        'repositoryID' => ep.slug,
        'label' => ep.description,
        'ruleset' => 'owl-horst-optimized',
        'base-URL' => 'http://example.org/graphdb#'
      }.to_json,
      :headers => {
        'Authorization' => 'Basic ' + basicToken,
        'Content-Type' => 'application/json'
      }
    )
    puts request.inspect
    response = request.execute
    raise "Error creating new repository" unless response.code.between?(200, 299)

    rdf_repo.repo_hash = {repo_id: "DbmS4 repo_id #{type}:#{name}:#{rdf_repo.name}" }
    rdf_repo.is_public = ep.public
    rdf_repo.uri = url + '/' + ep.slug
    ep.uri = rdf_repo.uri

    # By default all newly created S4 repositories are private
    if rdf_repo.is_public
      update_repository_public(rdf_repo, rdf_repo.is_public)
    end

    puts "***** Exit DbmS4.create_repository()"
  end


  # Update S4 repository public property
  def update_repository_public(rdf_repo, public)
    puts "***** Enter DbmS4.set_repository_public(#{name})"
    puts rdf_repo.inspect
    puts public

    url = rdf_repo.uri
    api_key = rdf_repo.dbm.first_enabled_key
    basicToken = Base64.strict_encode64(api_key.key)

    request = RestClient::Request.new(
      :method => :post,
      :url => url,
      :payload => {
        'public' => public.to_s
      }.to_json,
      :headers => {
        'Authorization' => 'Basic' + ' ' + basicToken,
        'Cache-Control' => 'no-cache',
        'Content-Type' => 'application/json'
      }
    )

    puts request.inspect
    response = request.execute
    raise "Error updating S4 repository public property" unless response.code.between?(200, 299)

    rdf_repo.is_public = public
    rdf_repo.save

    puts "***** Exit DbmS4.set_repository_public()"
  end



  def used_sparql_count
    rdf_repo_list = self.rdf_repos.all
    return rdf_repo_list.size
  end


  def used_sparql_triples
    puts "***** Enter DbmS4.quota_used_sparql_triples(#{name})"
    total_repo_sparql_triples = 0
    total_cached_sparql_triples = 0
    cached_sparql_requests = 0

    rdf_repo_list = self.rdf_repos.all
    rdf_repo_list.each do |rr|
      total_repo_sparql_triples += rr.get_repository_size
    end
    res = {repo_triples: total_repo_sparql_triples, cached_triples: total_cached_sparql_triples, cached_req: cached_sparql_requests}
    puts "***** Exit DbmS4.quota_used_sparql_triples()"
    return res
  end


  # Get S4 database quota count for max repositories
  def quota_sparql_count()
    puts "***** Enter DbmS4.quota_sparql_count(#{name})"

    res = case self.db_plan
    when 'BL1' then
      1
    when 'BL2' then
      1
    when 'SL1' then
      2
    when 'SL2' then
      4
    when 'EL1' then
      8
    when 'EL2' then
      10
    when 'EL3' then
      16
    else
      1
    end

    puts "***** Exit DbmS4.quota_sparql_count()"
    return res
  end


  # Get S4 database quota count for max triples
  def quota_sparql_ktriples()
    puts "***** Enter DbmS4.quota_sparql_ktriples(#{name})"

    res = case self.db_plan
    when 'BL1' then
      100000
    when 'BL2' then
      1000000
    when 'SL1' then
      5000000
    when 'SL2' then
      10000000
    when 'EL1' then
      50000000
    when 'EL2' then
      250000000
    when 'EL3' then
      1000000000
    else
      100000
    end

    puts "***** Exit DbmS4.quota_sparql_ktriples()"
    return res
  end


  # Delete S4 repository
  def delete_repository(rdf_repo)
    puts "***** Enter DbmS4.delete_repository(#{name})"

    url = rdf_repo.uri.to_s.gsub("RR:", "")
    api_key = rdf_repo.dbm.first_enabled_key
    basicToken = Base64.strict_encode64(api_key.key)

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
    raise "Error deleting S4 repository" unless response.code.between?(200, 299)

    rdf_repo.repo_hash = {repo_id: 'deleted' }
    rdf_repo.uri = 'Deleted URI...'

    puts "***** Exit DbmS4.delete_repository()"
  end

  private
  # Delete all RDF repositories owned by this dbm called by before_destroy
  def unreg_before_destroy()
    puts "***** Enter DbmS4.unreg_before_destroy(#{name})"
    # Remove all rdf_repos referencing this dbm
    rdf_repos.all.each do |rr|
      rr.destroy
    end

    puts "***** Exit DbmS4.unreg_before_destroy()"
  end

end
