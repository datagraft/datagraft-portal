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

    def register_ontotext_account
      return if has_ontotext_account

      # We generate a random token so the process
      # should still work after a failure or if two
      # concurrents registration happen
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
          role: 'rails wrapper',
          # email: username+'_'+account_token.to_s+'@datagraft.net'
          email: 'a.pultier+'+account_token.to_s+'@gmail.com'
          }.to_json
        puts req.body
      end

      if resp.status.between?(200, 299)
        self.ontotext_account = account_token
        save!
      else 
        puts resp.body
        throw "Unable to register an Ontotext User"
      end

      conn
    end

    def ontotext_connexion(use_api_key = false)

      unless has_ontotext_account
        conn = register_ontotext_account
        return conn unless use_api_key
      end

      conn = new_api_connexion

      if use_api_key
        key = api_keys.where(enabled: true).first

        # Create a key if one doesn't exist yet
        if key.nil?
          key = ApiKey.new
          key.enabled = true
          key.name = 'Default Ontotext API Key'
          key.user = self
          key.key = key.new_ontotext_api_key(self)
          key.save

          # TODO : Check if this definitely removes the bad credentials bug…
          sleep 3
        end

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
    def ontotext_api_keys
      lol = ontotext_connexion.get do |req|
        req.url '/dapaas-management-services/api/api_keys'
      end

      # throw lol.status
    end

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

    def delete_ontotext_api_key(key)
      resp = ontotext_connexion.delete do |req|
        req.url '/dapaas-management-services/api/api_keys/'+key
      end
    end

    def enable_ontotext_api_key(key)
      resp = ontotext_connexion.put do |req|
        req.headers['Content-Type'] = 'application/json'
        req.url '/dapaas-management-services/api/api_keys/'+key+'/enable'
      end
    end

    def disable_ontotext_api_key(key)
      resp = ontotext_connexion.put do |req|
        req.headers['Content-Type'] = 'application/json'
        req.url '/dapaas-management-services/api/api_keys/'+key+'/disable'
      end
    end

    def has_ontotext_account
      ontotext_account != 0
    end

    def new_ontotext_repository(qds)
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
          'dcat:public' => 'false',
          'dct:modified'=> today,
          'dct:issued' => today
        }.to_json
        #throw req.body
      end

      throw ("Unable to create the Ontotext Dataset - " + resp_dataset.body) unless resp_dataset.status.between?(200, 299)

      json_dataset = JSON.parse(resp_dataset.body)

      resp_distribution = connect.post do |req|
        req.url '/catalog/distributions'
        req.headers['dataset-id'] = json_dataset['@id']
        req.body = {
          file: Faraday::UploadIO.new(StringIO.new(''), 'text/csv'),
          meta: Faraday::UploadIO.new(StringIO.new({
            '@context' => ontotext_declaration,
            '@type' => 'dcat:Distribution',
            'dct:title' => qds[:name].parameterize + ' distribution',
            'dct:description' => 'temporary empty file',
            'dcat:fileName' => 'empty.csv',
            'dcat:mediaType' => 'text/csv'
            }.to_json), 'application/ld+json'),
        }
      end 

      throw ("Unable to create the Ontotext Distribution - " + resp_distribution.body) unless resp_distribution.status.between?(200, 299)

      json_distribution = JSON.parse(resp_distribution.body)

      resp_repository = connect.put do |req|
        req.url '/catalog/distributions/repository'
        req.headers['Content-Type'] = 'application/ld+json'
        req.headers['distrib-id'] = json_distribution['@id']
        req.headers['repository-id'] = json_distribution['@id'].match(/[^\/]*$/)[0]
        req.options.timeout = 720
      end

      throw ("Unable to create the Ontotext Repository - " + resp_repository.body) unless resp_repository.status.between?(200, 299)

      json_repository = JSON.parse(resp_repository.body)

      return json_repository['access-url']
  end

  def delete_ontotext_repository(qds)
    connect = ontotext_connexion(true)
    connect.delete qds.uri
  end
end