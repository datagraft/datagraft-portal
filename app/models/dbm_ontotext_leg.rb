
class DbmOntotextLeg < Dbm

  # Assign this to a variable in the function that requires it
  # ENV['DBAAS_COORDINATOR_ENDPOINT']

  ######
  public
  ######

  @@supported_repository_types = %w(RDF)
  def get_supported_repository_types
    return @@supported_repository_types
  end

  # Overrides DBM method Returns the first enabled API key or creates key
  def first_enabled_key
    key = super

    # Create a key if one doesn't exist yet
    if key.nil?
      key = create_new_key
    end
    return key
  end


  # Create new OntotextLegacy repository
  def create_repository(rdf_repo, ep)
    puts "***** Enter DbmOntotextLeg.create_repository(#{name})"
    uri = new_ontotext_repository(ep)
    rdf_repo.repo_hash = {repo_id: "Dummy repo_id #{type}:#{name}:#{rdf_repo.name}" }
    rdf_repo.is_public = ep.public
    rdf_repo.uri = uri
    ep.uri = uri
    ep.repo_successfully_created

    puts "***** Exit DbmOntotextLeg.create_repository()"
  end

  # Update OntotextLegacy repository public property
  def update_repository_public(rdf_repo, public)
    puts "***** Enter DbmOntotextLeg.set_repository_public(#{name})"
    update_ontotext_repository_public(rdf_repo, public)

    puts rdf_repo.inspect
    puts public

    rdf_repo.is_public = public
    rdf_repo.save

    puts "***** Exit DbmOntotextLeg.set_repository_public()"
  end

  def used_sparql_count
    rdf_repo_list = self.rdf_repos.all
    return rdf_repo_list.size
  end

  def used_sparql_triples
    puts "***** Enter DbmOntotextLeg.quota_used_sparql_triples(#{name})"
    total_repo_sparql_triples = 0
    total_cached_sparql_triples = 0
    cached_sparql_requests = 0

    rdf_repo_list = self.rdf_repos.all
    rdf_repo_list.each do |rr|
      total_repo_sparql_triples += rr.get_repository_size
    end
    res = {repo_triples: total_repo_sparql_triples, cached_triples: total_cached_sparql_triples, cached_req: cached_sparql_requests}
    puts "***** Exit DbmOntotextLeg.quota_used_sparql_triples()"
    return res
  end

  # Get OntotextLegacy database quota count for max repositories
  def quota_sparql_count()
    puts "***** Enter DbmOntotextLeg.quota_sparql_count(#{name})"

    res = user.quota_sparql_count # Fetch from user profile
    ##TODO res = used_sparql_count # Return the current count to avoid creation of more

    puts "***** Exit DbmOntotextLeg.quota_sparql_count()"
    return res
  end

  # Get OntotextLegacy database quota count for max triples
  def quota_sparql_ktriples()
    puts "***** Enter DbmOntotextLeg.quota_sparql_ktriples(#{name})"

    res = user.quota_sparql_ktriples

    puts "***** Exit DbmOntotextLeg.quota_sparql_ktriples()"
    return res
  end

  # Delete OntotextLegacy repository
  def delete_repository(rdf_repo)
    puts "***** Enter DbmOntotextLeg.delete_repository(#{name})"
    begin
      connect = ontotext_connexion(true)
      connect.delete rdf_repo.uri

      rdf_repo.repo_hash = {repo_id: 'deleted' }
      rdf_repo.uri = 'Deleted URI...'
    rescue Exception => e
      puts 'Error deleting DbmOntotextLeg repository'
      puts e.message
      puts e.backtrace.inspect
    end
    puts "***** Exit DbmOntotextLeg.delete_repository()"
  end

  ######
  private
  ######

  # Rails 4 strong params usage
  def dbm_ontotext_leg_params
    params.require(:dbm_ontotext_leg).permit()
  end

  # Methods ported from ontotext_user.rb

  # Get ontotext api keys
  def ontotext_api_keys      #Checked
    lol = ontotext_connexion.get do |req|
      req.url '/dapaas-management-services/api/api_keys'
    end

    # throw lol.status
  end

  # Create new ontotext api key
  def new_ontotext_api_key(temporary=false)     #Checked
    url = '/dapaas-management-services/api/api_keys'
    url += '/temporary' if temporary
    resp = ontotext_connexion.post do |req|
      req.url url
      # kinda useless but the API crashes without it
      req.headers['Content-Type'] = 'application/json'
    end

    throw "Unable to create the API key" unless resp.status.between?(200, 299)

    JSON.parse resp.body
  end

  # Delete ontotext api key
  def delete_ontotext_api_key(key)      #Checked
    resp = ontotext_connexion.delete do |req|
      req.url '/dapaas-management-services/api/api_keys/'+key
    end
  end

  # Enable ontotext api key
  def enable_ontotext_api_key(key)  #Checked
    resp = ontotext_connexion.put do |req|
      req.headers['Content-Type'] = 'application/json'
      req.url '/dapaas-management-services/api/api_keys/'+key+'/enable'
    end
  end

  # Disable ontotext api key
  def disable_ontotext_api_key(key)    #Checked
    resp = ontotext_connexion.put do |req|
      req.headers['Content-Type'] = 'application/json'
      req.url '/dapaas-management-services/api/api_keys/'+key+'/disable'
    end
  end

  # Check if user has ontotext account
  def has_ontotext_account     #Checked
    ontotext_account != 0
  end

  # Use users account
  def ontotext_account
    user.ontotext_account
  end

  # Use users password
  def encrypted_password
    user.encrypted_password
  end

  # Use users name
  def username
    user.username
  end


  # Decode Ontotext user ID based on RDF repo URI
  def decode_ontotext_user_id(rr)      #Checked
    encoded_id = rr.uri.split('/')[3]
    encoded_id_length = encoded_id.length

    decoded_id = ""
    for i in 0..encoded_id_length-1
      #      puts("i = #{i}, encoded_id[#{i}] = #{encoded_id[i]}")
      newValue = (encoded_id[i].to_i + 10 - 3) % 10
      #      puts("newValue = #{newValue}")
      decoded_id = decoded_id + newValue.to_s
    end

    return decoded_id
  end

  # Get Ontotext DB ID belonging to the Ontotext user account
  def get_ontotext_db_id(ontotext_user_id)       #Checked
    begin
      url = ENV['DBAAS_COORDINATOR_ENDPOINT']+'users/'+ontotext_user_id+'/db'
      connect = Faraday.new
      resp = connect.get do |req|
        req.url url
        req.headers['Content-Type'] = 'application/ld+json'
        req.options.timeout = 720
      end

      throw ("Unable to get Ontotext DB ID - " + resp.body + " - " + resp.status) unless resp.status.between?(200, 299)

      json_resp = JSON.parse(resp.body)

      return json_resp[0]['db-id']

    rescue Exception => e
      puts 'Error getting Ontotext DB ID'
      puts e.message
      puts e.backtrace.inspect
    end
  end


  # Update the public property of the repository
  def update_ontotext_repository_public(rr, public)   #TODO
    begin
      user_id = decode_ontotext_user_id(rr)
      db_id = get_ontotext_db_id(user_id)
      repository_id = rr.uri.split('/')[6]
      url = ENV['DBAAS_COORDINATOR_ENDPOINT']+'db/'+db_id+'/repository/'+repository_id
      body = '{"public": ' + '"' + public.to_s + '"}'

      connect = Faraday.new
      resp = connect.post do |req|
        req.url url
        req.headers['Content-Type'] = 'application/json'
        req.body = body
        req.options.timeout = 720
      end

      throw ("Unable to update Ontotext repository public property - " + resp.body + " - " + resp.status) unless
      resp.status.between?(200, 299)

      return resp.body

    rescue Exception => e
      puts 'Error updating Ontotext repository public property'
      puts e.message
      puts e.backtrace.inspect
    end
  end








  # Create new ontotext repository
  def new_ontotext_repository(thing)     #Checked
    begin
      pname = thing[:name].parameterize
      today = Time.now.to_s.slice(0,10)

      connect = ontotext_connexion(true)
      resp_dataset = connect.post do |req|
        req.url '/catalog/datasets'
        req.headers['Content-Type'] = 'application/ld+json'
        req.body = {
          '@context' => ontotext_declaration,
          'dct:title' => thing[:name].parameterize,
          'dct:description' => thing[:description].to_s,
          'dcat:public' => thing[:public].to_s,
          'dct:modified'=> today,
          'dct:issued' => today
          }.to_json
        #throw req.body
      end

      throw ("Unable to create the Ontotext Dataset - " + resp_dataset.body + " - " + resp_dataset.status.to_s) unless resp_dataset.status.between?(200, 299)

      json_dataset = JSON.parse(resp_dataset.body)

      resp_distribution = connect.post do |req|
        req.url '/catalog/distributions'
        req.headers['dataset-id'] = json_dataset['@id']
        req.body = {
          file: Faraday::UploadIO.new(StringIO.new(''), 'text/csv'),
          meta: Faraday::UploadIO.new(StringIO.new({
            '@context' => ontotext_declaration,
            '@type' => 'dcat:Distribution',
            'dct:title' => thing[:name].parameterize + '-distribution',
            'dct:description' => 'temporary empty file',
            'dcat:fileName' => 'empty.csv',
            'dcat:mediaType' => 'text/csv'
            }.to_json), 'application/ld+json'),
          }
      end

      throw ("Unable to create the Ontotext Distribution - " + resp_distribution.body + " - " + resp_distribution.status.to_s) unless resp_distribution.status.between?(200, 299)

      json_distribution = JSON.parse(resp_distribution.body)

      # Compute a repository ID from the distribution ID
      repository_id = json_distribution['@id'].match(/[^\/]*$/)[0].sub(/(.*)-distribution/, "\\1")

      resp_repository = connect.put do |req|
        req.url '/catalog/distributions/repository'
        req.headers['Content-Type'] = 'application/ld+json'
        req.headers['distrib-id'] = json_distribution['@id']
        req.headers['repository-id'] = repository_id
        req.options.timeout = 720
      end

      throw ("Unable to create the Ontotext Repository - " + resp_repository.body + " - " + resp_repository.status.to_s) unless resp_repository.status.between?(200, 299)

      json_repository = JSON.parse(resp_repository.body)

      return json_repository['access-url']

    rescue Exception => e
      thing.error_occured_creating_repo
      puts 'Error creating Ontotext repository'
      puts e.message
      puts e.backtrace.inspect
    end
  end




  # Methods ported from api_key.rb
  def get_key_without_secret(key)   #Checked
    r = /^(.+):/.match(key)
    r ? r[1] : nil
  end

  def create_new_key()     #Checked
    ont_key = new_ontotext_api_key

    # We store the secret because we don't give a duck
    key = add_key('Automatically generated Ontotext API Key', ont_key['api_key']+':'+ont_key['secret'])

    # TODO : Check if this definitely removes the bad credentials bug…
    sleep 5

    return key
  end



  # Methods ported from ontotext_user.rb
  def new_api_connexion       #Checked
    Faraday.new(:url => 'https://api.datagraft.net') do |faraday|
      faraday.request :multipart
      faraday.request :url_encoded

      faraday.response :logger                  # log requests to STDOUT
      faraday.use :cookie_jar                   # yes we do use cookies
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end

  # Register new ontotext account
  def register_ontotext_account    #Checked
    return if has_ontotext_account

    throw "User doesnt have a registered Ontotext user"
  end

  # Create an ontotext connection
  def ontotext_connexion(use_api_key = false)    #Checked
    unless has_ontotext_account
      conn = register_ontotext_account
      return conn unless use_api_key
    end

    conn = new_api_connexion

    if use_api_key
      key = first_enabled_key

      basicToken = Base64.strict_encode64(key.key)

      conn.authorization :Basic, basicToken
    else
      resp = conn.put do |req|
        req.url '/dapaas-management-services/api/accounts/login'
        req.headers['Content-Type'] = 'application/json'
        req.body = {
          username: username+'_'+ontotext_account.to_s,
          password: encrypted_password
          }.to_json
      end

      # throw resp.headers
      throw ontotext_account unless resp.status.between?(200, 299)
    end

    conn
  end

  # Ontotext declaration
  def ontotext_declaration    #Checked
    {
      dcat:'http://www.w3.org/ns/dcat#',
      foaf:'http://xmlns.com/foaf/0.1/',
      dct:'http://purl.org/dc/terms/',
      xsd:'http://www.w3.org/2001/XMLSchema#',
      'dct:issued' => {'@type' => 'xsd:date'},
      'dct:modified' => {'@type' => 'xsd:date'},
      'foaf:primaryTopic' => {'@type' => '@id'},
      'dcat:distribution' => {'@type' => '@id'}
      }
  end



end
