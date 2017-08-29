require 'rest-client'

class DbmS4 < Dbm
  # Non-persistent attribute for storing inputs from new form
  attr_accessor :dbm_account_username
  attr_accessor :dbm_account_password
  

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
  
  def key
    configuration["key"] if configuration
  end
  
  def key=(val)
    touch_configuration!
    configuration["key"] = val
  end  
  
  def secret
    configuration["secret"] if configuration
  end
  
  def secret=(val)
    touch_configuration!
    configuration["secret"] = val
  end
  
  
  # Create new S4 repository
  def create_repository(rdf_repo, ep)
    puts "***** Enter DbmS4.create_repository(#{name})"
    
    today = Time.now.to_s.slice(0,10)

    url = rdf_repo.dbm.endpoint + '/repositories'
    key = rdf_repo.dbm.key + ':' + rdf_repo.dbm.secret
    basicToken = Base64.strict_encode64(key)
      
    request = RestClient::Request.new(
      :method => :put,
      :url => url,
      :payload => {
        'repositoryID' => ep.name,
        'label' => ep.description,
        'ruleset' => 'owl-horst-optimized',
        'base-URL' => 'http://example.org/graphdb#'
      }.to_json,
      :headers => {
        'Authorization' => 'Basic ' + basicToken,
        'Content-Type' => 'application/json'
      }
    )

    begin
      response = request.execute
      throw "Error creating new repository" unless response.code.between?(200, 299)

      rdf_repo.repo_hash = {repo_id: "Dummy repo_id #{type}:#{name}:#{rdf_repo.name}" }
      rdf_repo.is_public = ep.public
      rdf_repo.uri = url + '/' + ep.name
      ep.uri = rdf_repo.uri
      
      # By default all newly created S4 repositories are private
      if rdf_repo.is_public
        set_repository_public(rdf_repo)
      end

      ep.repo_successfully_created
    rescue Exception => e
      ep.error_occured_creating_repo
      puts 'Error creating S4 repository'
      puts e.message
      puts e.backtrace.inspect
    end

    puts "***** Exit DbmS4.create_repository()"
  end

  
  # Upload file to S4 repository (TO-BE-DELETED)
  # Since this code is not S4-specific it has been moved to the rdf_repo.rb model
=begin
  def upload_file_to_repository(rdf_repo, file, file_type)
    puts "***** Enter DbmS4.upload_file_to_repository(#{name})"
    
    url = rdf_repo.uri + '/statements'
    key = rdf_repo.dbm.key + ':' + rdf_repo.dbm.secret
    basicToken = Base64.strict_encode64(key)

    mime_type = case file_type
    when 'rdf' then
      'application/rdf+xml'
    when 'nt' then
      'text/plain'
    when 'ttl' then
      'application/x-turtle'
    when 'n3' then
      'text/rdf+n3'
    when 'trix' then
      'application/trix'
    when 'trig' then
      'application/x-trix'
    else
      'text/plain'
    end

    request = RestClient::Request.new(
      :method => :post,
      :url => url,
      :payload => file.read,
      :headers => {
        'Authorization' => 'Basic ' + basicToken,
        'Content-Type' => mime_type
      }
    )

    begin
      response = request.execute
      throw "Error uploading file to S4 repository" unless response.code.between?(200, 299)
    
      puts rdf_repo.inspect
      puts file.inspect
      puts file_type.inspect
    rescue Exception => e
      puts 'Error uploading file to S4 repository'
      puts e.message
      puts e.backtrace.inspect
    end

    puts "***** Exit DbmS4.upload_file_to_repository()"
  end
=end
  
  # Query S4 repository (TO-BE-DELETED)
  # Since this code is not S4-specific it has been moved to the rdf_repo.rb model
=begin
  def query_repository(db_repository, query_string)
    puts "***** Enter DbmS4.query_repository(#{name})"
    puts query_string
    res = {"head" => {"vars" => ["s", "p", "o"]}, "results" => {"bindings"=>[{"p"=>{"type"=>"uri", "value"=>"p-dummy"}, "s"=>{"type"=>"uri", "value"=>"s-dummy"}, "o"=>{"type"=>"uri", "value"=>"o-dummy"}}]}}
    puts "***** Exit DbmS4.query_repository()"
    return res
  end
=end
  
  # Update public property of S4 repository (TO-BE-DELETED)
  # This method overlaps with set_repository_public and can be merged
  # Be sure to update the reference to this method from SPARQL endpoint when refactoring
  def update_ontotext_repository_public(rdf_repo, public)
    puts "***** Enter DbmS4.update_ontotext_repository_public(#{name})"
    puts rdf_repo.inspect
    puts public
    
    rdf_repo.is_public = public
    set_repository_public(rdf_repo)
    
    puts "***** Exit DbmS4.update_ontotext_repository_public()"
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

  
  # Get S4 repository size
  def get_repository_size(rdf_repo)
    puts "***** Enter DbmS4.get_repository_size(#{name})"
    
    return '0' if not rdf_repo.uri

    url = rdf_repo.uri + '/size'
    key = rdf_repo.dbm.key + ':' + rdf_repo.dbm.secret
    basicToken = Base64.strict_encode64(key)

    # No user authentication required for public SPARQL endpoints
    if rdf_repo.is_public
      request = RestClient::Request.new(
        :method => :get,
        :url => url,
        :headers => {
          'Content-Type' => 'application/json'
        }
      )
    else
      request = RestClient::Request.new(
        :method => :get,
        :url => url,
        :headers => {
          'Authorization' => 'Basic ' + basicToken,
          'Content-Type' => 'application/json'
        }
      )
    end

    begin
      response = request.execute
      throw "Error getting repository size" unless response.code.between?(200, 299)

      puts response.inspect

      # Update cached size of RDF repository
      rdf_repo.cached_size = response.body ||= rdf_repo.cached_size
      rdf_repo.save

      return response.body
    end
    
    puts "***** Exit DbmS4.get_repository_size()"
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


  # Set S4 repository public property
  def set_repository_public(rdf_repo)
    puts "***** Enter DbmS4.set_repository_public(#{name})"
    
    today = Time.now.to_s.slice(0,10)

    url = rdf_repo.uri
    key = rdf_repo.dbm.key + ':' + rdf_repo.dbm.secret
    basicToken = Base64.strict_encode64(key)
  
    request = RestClient::Request.new(
      :method => :post,
      :url => url,
      :payload => {
        'public' => rdf_repo.is_public.to_s
      }.to_json,
      :headers => {
        'Authorization' => 'Basic' + ' ' + basicToken,
        'Cache-Control' => 'no-cache',
        'Content-Type' => 'application/json'
      }
    )

    begin
      response = request.execute
      throw "Error setting repository public" unless response.code.between?(200, 299)
    
    rescue Exception => e
      puts 'Error setting S4 repository public'
      puts e.message
      puts e.backtrace.inspect
    end
    
    puts "***** Exit DbmS4.set_repository_public()"
  end
  
  
  # Delete S4 repository
  def delete_repository(rdf_repo)
    puts "***** Enter DbmS4.delete_repository(#{name})"

    today = Time.now.to_s.slice(0,10)
    
    url = rdf_repo.uri.to_s.gsub("RR:", "")
    key = rdf_repo.dbm.key + ':' + rdf_repo.dbm.secret
    basicToken = Base64.strict_encode64(key)

    request = RestClient::Request.new(
      :method => :delete,
      :url => url,
      :headers => {
        'Authorization' => 'Basic ' + basicToken,
        'Content-Type' => 'application/json'
      }
    )

    begin
      response = request.execute
      throw "Error deleting S4 repository" unless response.code.between?(200, 299)
    
      rdf_repo.repo_hash = {repo_id: 'deleted' }
      rdf_repo.uri = 'Deleted URI...'
    rescue Exception => e
      puts 'Error deleting S4 repository'
      puts e.message
      puts e.backtrace.inspect
    end
    puts "***** Exit DbmS4.delete_repository()"
  end    

end
