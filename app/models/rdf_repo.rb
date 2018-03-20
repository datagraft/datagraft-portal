require 'rest-client'

class RdfRepo < ApplicationRecord
  belongs_to :dbm
  has_many :things
  before_destroy :delete_repository

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

    url = self.uri + '/statements'

    basicToken = self.dbm.get_authorization_token

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

    puts request.inspect
    response = request.execute
    raise "Error uploading file to RDF repository" unless response.code.between?(200, 299)
    puts file.inspect
    puts file_type.inspect

    puts "***** Exit RdfRepo.upload_file_to_repository()"
  end


  # Query RDF repository
  def query_repository_proxy(query_string, accept_string)
    puts "***** Enter RdfRepo.query_repository_proxy(#{name})"

    url = self.uri

    # User authentication required for private RDF repositories (SPARQL endpoints)
    if !self.is_public
      basicToken = self.dbm.get_authorization_token

      headers = {
        :params => {
          'query' => query_string
        },
        'Authorization' => 'Basic ' + basicToken,
        'Accept' => accept_string
      }
    else
      headers = {
        :params => {
          'query' => query_string
        },
        'Accept' => accept_string
      }
    end

    request = RestClient::Request.new(
      :method => :get,
      :url => url,
      :headers => headers
    )

    response = request.execute
    raise "Error querying RDF repository" unless response.code.between?(200, 299)


    puts "***** Exit RdfRepo.query_repository_proxy()"
    return response
  end


  # Query RDF repository
  def query_repository(query_string)
    puts "***** Enter RdfRepo.query_repository(#{name})"

    url = self.uri

    # User authentication required for private RDF repositories (SPARQL endpoints)
    if !self.is_public
      basicToken = self.dbm.get_authorization_token

      headers = {
        :params => {
          'query' => query_string
        },
        'Authorization' => 'Basic ' + basicToken,
        'Accept' => 'application/sparql-results+json'
      }
    else
      headers = {
        :params => {
          'query' => query_string
        },
        'Accept' => 'application/sparql-results+json'
      }
    end

    request = RestClient::Request.new(
      :method => :get,
      :url => url,
      :headers => headers
    )

    puts request.inspect
    response = request.execute
    raise "Error querying RDF repository" unless response.code.between?(200, 299)

    puts response.inspect

    puts "***** Exit RdfRepo.query_repository()"
    return response
  end


  # Update public property of RDF property
  def update_repository_public(public)
    puts "***** Enter RdfRepo.update_repository_public(#{name})"
    dbm.update_repository_public(self, public)
    puts "***** Exit RdfRepo.update_repository_public()"
  end


  # Get RDF repository size
  def get_repository_size()
    puts "***** Enter RdfRepo.get_repository_size(#{name})"
    query_string = "SELECT (count(*) as ?count) WHERE { ?s ?p ?o . }"

    begin
      response = query_repository(query_string)

      puts response.inspect
      triples_count = JSON.parse(response.body)["results"]["bindings"].first["count"]["value"].to_i
      self.cached_size = triples_count ||= self.cached_size
      self.save

    rescue => e
      puts 'Error querying repo size - using cached value'
      puts e.message
      #puts e.backtrace.inspect
    end

    puts "***** Exit RdfRepo.get_repository_size()"

    res = self.cached_size
    res = 0 if res == nil
    return res
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

  def read_size_wo_key_for_test

    url = self.uri + '/size'

    headers = {
      'Accept' => 'application/sparql-results+json'
    }
    request = RestClient::Request.new(
      :method => :get,
      :url => url,
      :headers => headers
    )
    puts request.inspect
    response = request.execute

    return response.body.to_i
  end


  protected
  def touch_configuration!
    self.configuration = {} if not configuration.is_a?(Hash)
  end

  private
  # Delete RDF repository called by before_destroy
  def delete_repository()
    puts "***** Enter RdfRepo.delete_repository(#{name})"
    # Remove all things referencing this rr
    things.all.each do |thing|
      thing.rdf_repo = nil  # Avoid recursive calls to delete_repository
      thing.save
      #thing.destroy
    end
    dbm.delete_repository(self) unless self.uri == nil

    return true
    puts "***** Exit RdfRepo.delete_repository()"
  end


end
