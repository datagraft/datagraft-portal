# Assign this to a variable in the function that requires it
# ENV['DBAAS_COORDINATOR_ENDPOINT']

module OntotextUser
  private
  def new_api_connexion
    Faraday.new(:url => 'https://api.datagraft.net') do |faraday|
      faraday.request :multipart
      faraday.request :url_encoded

      faraday.response :logger                  # log requests to STDOUT
      faraday.use :cookie_jar                   # yes we do use cookies
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end

  # Register new ontotext account
  def register_ontotext_account
    return if has_ontotext_account

    # We generate a random token so the process should still work after a failure
    # or if two concurrents registration happen.
    # The Ontotext db requires both usernames and emails to be unique.
    # Thus we need the random token to ensure uniqueness of these.
    # We should ask Ontotext to remove the uniqeness requirement for emails.
    account_token = rand(1..100000000).to_i

    conn = new_api_connexion
    resp = conn.post do |req|
      req.options[:timeout] = 5
      req.url '/dapaas-management-services/api/accounts'
      req.headers['Content-Type'] = 'application/json'
      req.body = {
        username: username+'_'+account_token.to_s,
        password: encrypted_password,
        name: name,
        role: ENV['RAILS_ENV'],
        # email: self.email
        email: 'a.pultier+'+account_token.to_s+'@gmail.com'
        }.to_json
      puts req.body
    end

    if resp.status.between?(200, 299)
      self.ontotext_account = account_token
      save!
    else
      puts resp.body
      throw "Unable to register an Ontotext user"
    end

    conn
  end

  # Register new ontotext test account (only used for testing)
  def register_ontotext_test_account
    return if has_ontotext_account

    # The Ontotext db requires both usernames and emails to be unique.
    # In the register ontotext account method we generate a random token
    # to ensure uniqueness of these. For the test user we set a fixed token.
    account_token = 100000003

    conn = new_api_connexion
    resp = conn.post do |req|
      req.options[:timeout] = 5
      req.url '/dapaas-management-services/api/accounts'
      req.headers['Content-Type'] = 'application/json'
      req.body = {
        username: username+'_'+account_token.to_s,
        password: password,
        name: name,
        role: ENV['RAILS_ENV'],
        # email: self.email
        email: 'a.pultier+'+account_token.to_s+'@gmail.com'
        }.to_json
      puts req.body
    end

    if resp.status.between?(200, 299)
      self.ontotext_account = account_token
      save!
    else
      puts resp.body
      throw "Unable to register an Ontotext test user"
    end

    conn
  end

  # Create an ontotext connection
  def ontotext_connexion(use_api_key = false)
    unless has_ontotext_account
      conn = register_ontotext_account
      return conn unless use_api_key
    end

    conn = new_api_connexion

    if use_api_key
      key = ApiKey.first_or_create(self)

      basicToken = Base64.strict_encode64(key.key)

      conn.authorization :Basic, basicToken
    else
      resp = conn.put do |req|
        req.url '/dapaas-management-services/api/accounts/login'
        req.headers['Content-Type'] = 'application/json'
        req.body = {
          username: username+'_'+self.ontotext_account.to_s,
          password: encrypted_password
          }.to_json
      end

      # throw resp.headers
      throw self.ontotext_account unless resp.status.between?(200, 299)
    end

    conn
  end

  # Ontotext declaration
  def ontotext_declaration
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

  public
  # Get ontotext api keys
  def ontotext_api_keys
    lol = ontotext_connexion.get do |req|
      req.url '/dapaas-management-services/api/api_keys'
    end

    # throw lol.status
  end

  # Create new ontotext api key
  def new_ontotext_api_key(temporary=false)
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
  def delete_ontotext_api_key(key)
    resp = ontotext_connexion.delete do |req|
      req.url '/dapaas-management-services/api/api_keys/'+key
    end
  end

  # Enable ontotext api key
  def enable_ontotext_api_key(key)
    resp = ontotext_connexion.put do |req|
      req.headers['Content-Type'] = 'application/json'
      req.url '/dapaas-management-services/api/api_keys/'+key+'/enable'
    end
  end

  # Disable ontotext api key
  def disable_ontotext_api_key(key)
    resp = ontotext_connexion.put do |req|
      req.headers['Content-Type'] = 'application/json'
      req.url '/dapaas-management-services/api/api_keys/'+key+'/disable'
    end
  end

  # Check if user has ontotext account
  def has_ontotext_account
    ontotext_account != 0
  end

  # Create new ontotext repository
  def new_ontotext_repository(qds)
    begin
      pname = qds[:name].parameterize
      today = Time.now.to_s.slice(0,10)

      connect = ontotext_connexion(true)
      resp_dataset = connect.post do |req|
        req.url '/catalog/datasets'
        req.headers['Content-Type'] = 'application/ld+json'
        req.body = {
          '@context' => ontotext_declaration,
          'dct:title' => qds[:name].parameterize,
          'dct:description' => qds[:description].to_s,
          'dcat:public' => qds[:public].to_s,
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
            'dct:title' => qds[:name].parameterize + '-distribution',
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
      puts 'Error creating Ontotext repository'
      puts e.message
      puts e.backtrace.inspect
    end
  end


  # Delete ontotext repository
  def delete_ontotext_repository(qds)
    connect = ontotext_connexion(true)
    connect.delete qds.uri
  end


  # Get the size of the repository
  def get_ontotext_repository_size(se)
    begin
      return 'unknown size of' if not se.uri

      # No user authentication required for public SPARQL endpoints
      connect = Faraday.new
      if not se.public
        # User authentication required for private SPARQL endpoints
        connect = ontotext_connexion(true)
      end

      resp_size = connect.get do |req|
        req.url se.uri+'/size'
        req.headers['Content-Type'] = 'application/ld+json'
        req.options.timeout = 10
      end

      throw ("Unable to get size of the Ontotext repository - " + resp_size.body.to_s + " - " + resp_size.status.to_s) unless
      resp_size.status.between?(200, 299)

      puts resp_size.inspect
      
      # Update cached size of Sparql Endpoint
      se.cached_size = resp_size.body
      se.save
      
      return resp_size.body

#    rescue Exception => e
#      puts 'Error getting Ontotext repository size'
#      puts e.message
#      puts e.backtrace.inspect
#      throw e

#      return 'unknown size of'
    end
  end


  # Upload file to the repository
  def upload_file_ontotext_repository(rdfFile, rdfType, sparql_endpoint)
    begin
      mime_type = case rdfType
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

        connect = ontotext_connexion(true)
        resp = connect.post do |req|
          req.url sparql_endpoint.uri+'/statements'
          req.headers['Content-Type'] = mime_type
          req.body = rdfFile.read
          req.options.timeout = 720
        end

        throw ("Unable to upload file to the Ontotext repository - " + resp.body.to_s + " - " + resp.status.to_s) unless
        resp.status.between?(200, 299)

      rescue Exception => e
        puts 'Error uploading file to Ontotext repository'
        puts e.message
        puts e.backtrace.inspect

        throw e
        #ensure
        # nothing
      end
      end


        # Decode Ontotext user ID based on SPARQL endpoint URI
        def decode_ontotext_user_id(sparql_endpoint)
          encoded_id = sparql_endpoint.uri.split('/')[3]
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
        def get_ontotext_db_id(ontotext_user_id)
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
        def update_ontotext_repository_public(se)
          begin
            user_id = decode_ontotext_user_id(se)
            db_id = get_ontotext_db_id(user_id)
            repository_id = se.uri.split('/')[6]
            url = ENV['DBAAS_COORDINATOR_ENDPOINT']+'db/'+db_id+'/repository/'+repository_id
            body = '{"public": ' + '"' + se.public.to_s + '"}'

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


        # Get login status
        def get_login_status(connect)
          resp = connect.get do |req|
            req.url '/dapaas-management-services/api/accounts/login_status'
            req.headers['Content-Type'] = 'application/ld+json'
            req.options.timeout = 720
          end

          throw ("Unable to get the login status - " + resp.body + " - " + resp.status) unless resp.status.between?(200, 299)

          return resp.body
        end


        # Ontotext login
        def ontotext_login
          connect = new_api_connexion

          resp = connect.put do |req|
            req.url '/dapaas-management-services/api/accounts/login'
            req.headers['Content-Type'] = 'application/json'
            req.body = {
              username: username+'_'+self.ontotext_account.to_s,
              password: encrypted_password
              }.to_json
          end

          throw ("Unable to login - " + resp.status.to_s) unless resp.status.between?(200, 299)

          return connect
        end

        # Delete ontotext account
        def delete_ontotext_account
          # Logs in the ontotext user
          connect = ontotext_connexion(false)

          # Deletes the ontotext user account
          resp = connect.delete do |req|
            req.url '/dapaas-management-services/api/accounts'
            req.headers['Content-Type'] = 'application/ld+json'
            req.options.timeout = 720
          end

          throw ("Unable to delete Ontotext account - " + resp.body + " - " + resp.status) unless resp.status.between?(200, 299)

          return resp.body
        end

      end
