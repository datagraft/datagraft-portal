require 'rest-client'

class RdfRepo < ApplicationRecord
  belongs_to :dbm
  has_many :things
  
  ######
  public
  ######
  
  def is_public
    configuration["is_public"] if configuration
  end

  def is_public=(val)
    touch_configuration!
    configuration["is_public"] = val
  end
  

  # Create RDF repository
  def create_repository(ep)
    puts "***** Enter RdfRepo.create_repository(#{name})"
    dbm.create_repository(self, ep)
    puts repo_hash
    puts "***** Exit RdfRepo.create_repository()"
  end

  
  # Upload file to RDF repository
  def upload_file_to_repository(file, file_type)
    puts "***** Enter RdfRepo.upload_file_to_repository(#{name})"
    #dbm.upload_file_to_repository(self, file, file_type)
    
    url = self.uri + '/statements'
    key = self.dbm.key + ':' + self.dbm.secret
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
      throw "Error uploading file to RDF repository" unless response.code.between?(200, 299)
    
      puts rdf_repo.inspect
      puts file.inspect
      puts file_type.inspect
    rescue Exception => e
      puts 'Error uploading file to RDF repository'
      puts e.message
      puts e.backtrace.inspect
    end
    
    puts "***** Exit RdfRepo.upload_file_to_repository()"
  end


  # Query RDF repository
  def query_repository(query_string)
    puts "***** Enter RdfRepo.query_repository(#{name})"
#    res = dbm.query_repository(self, query_string)
    
    url = self.uri
    key = self.dbm.key + ':' + self.dbm.secret
    basicToken = Base64.strict_encode64(key)
    
    # No user authentication required for public SPARQL endpoints
    if self.is_public
      request = RestClient::Request.new(
        :method => :get,
        :url => url,
        :headers => {
          :params => {
            'query' => query_string
          },
          'Accept' => 'application/sparql-results+json'
        }
      )
    else
      request = RestClient::Request.new(
        :method => :get,
        :url => url,
        :headers => {
          :params => {
            'query' => query_string
          },
          'Authorization' => 'Basic ' + basicToken,
          'Accept' => 'application/sparql-results+json'
        }
      )
    end
  
    begin
      response = request.execute
      throw "Error querying RDF repository" unless response.code.between?(200, 299)

      puts response.inspect
    rescue Exception => e
      puts 'Error querying RDF repository'
      puts e.message
      puts e.backtrace.inspect    
    end
    
    puts "***** Exit RdfRepo.query_repository()"
    return response
  end

  
  # Update public property of RDF property
  def update_ontotext_repository_public(public)
    puts "***** Enter RdfRepo.update_ontotext_repository_public(#{name})"
    dbm.update_ontotext_repository_public(self, public)
    puts "***** Exit RdfRepo.update_ontotext_repository_public()"
  end
      

  # Get RDF repository size
  def get_repository_size()
    puts "***** Enter RdfRepo.get_repository_size(#{name})"
    res = dbm.get_repository_size(self)

    url = self.uri
    key = self.dbm.key + ':' + self.dbm.secret
    basicToken = Base64.strict_encode64(key)
    
    query_string = "SELECT (count(*) as ?count) WHERE { ?s ?p ?o . }"
    
    # No user authentication required for public SPARQL endpoints
    if self.is_public
      request = RestClient::Request.new(
        :method => :get,
        :url => url,
        :headers => {
          :params => {
            'query' => query_string
          },
          'Accept' => 'application/sparql-results+json'
        }
      )
    else
      request = RestClient::Request.new(
        :method => :get,
        :url => url,
        :headers => {
          :params => {
            'query' => query_string
          },
          'Authorization' => 'Basic ' + basicToken,
          'Accept' => 'application/sparql-results+json'
        }
      )
    end
  
    begin
      response = request.execute
      throw "Error querying RDF repository" unless response.code.between?(200, 299)

      puts response.inspect
    rescue Exception => e
      puts 'Error querying RDF repository'
      puts e.message
      puts e.backtrace.inspect    
    end
    
    triples_count = JSON.parse(response.body)["results"]["bindings"].first["count"]["value"].to_i
    
    self.cached_size = triples_count ||= self.cached_size
    self.save
    
    # TODO fix cached size
    #ep.cached_size = resp_size.body ||= ep.cached_size
    #ep.save
    
    puts "***** Exit RdfRepo.get_repository_size()"
    return triples_count
  end

  
  # Delete RDF repository
  def delete_repository()
    puts "***** Enter RdfRepo.delete_repository(#{name})"
    dbm.delete_repository(self)
    puts "***** Exit RdfRepo.delete_repository()"
  end


  def has_configuration?(key)
    !get_configuration(key).nil?
  end

  def get_configuration(key)
    # throw configuration
    Rodash.get(configuration, key)
  end

  def repo_hash
    get_configuration("repo_hash")
  end

  def repo_hash=(val)
    touch_configuration!
    self.configuration["repo_hash"] = val
  end

  def uri
    get_configuration("uri")
  end

  def uri=(val)
    touch_configuration!
    self.configuration["uri"] = val
  end

  def name
    get_configuration("name")
  end

  def name=(val)
    touch_configuration!
    self.configuration["name"] = val
  end

  def cached_size
    get_configuration("cached_size")
  end

  def cached_size=(val)
    touch_configuration!
    self.configuration["cached_size"] = val
  end

  protected
  def touch_configuration!
    self.configuration = {} if not configuration.is_a?(Hash)
  end

end
