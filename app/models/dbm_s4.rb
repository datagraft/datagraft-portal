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
    params.require(:dbm_s4).permit(:public, :dbm_account_username, :dbm_account_password, :name, :endpoint, :key, :secret)
  end
  

  ######
  public
  ######
  
  @@supported_repository_types = %w(RDF)
  
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

  
  def upload_file_to_repository(rdf_repo, file, file_type)
    puts "***** Enter DbmS4.upload_file_to_repository(#{name})"
    puts rdf_repo.inspect
    puts file.inspect
    puts file_type.inspect
    puts "***** Exit DbmS4.upload_file_to_repository()"
  end

  
  def query_repository(db_repository, query_string)
    puts "***** Enter DbmS4.query_repository(#{name})"
    puts query_string
    res = {"head" => {"vars" => ["s", "p", "o"]}, "results" => {"bindings"=>[{"p"=>{"type"=>"uri", "value"=>"p-dummy"}, "s"=>{"type"=>"uri", "value"=>"s-dummy"}, "o"=>{"type"=>"uri", "value"=>"o-dummy"}}]}}
    puts "***** Exit DbmS4.query_repository()"
    return res
  end

  
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

  
  def quota_sparql_count()
    puts "***** Enter DbmS4.quota_sparql_count(#{name})"
    res = id
    puts "***** Exit DbmS4.quota_sparql_count()"
    return res
  end

  
  def quota_sparql_ktriples()
    puts "***** Enter DbmS4.quota_sparql_ktriples(#{name})"
    res = id
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
