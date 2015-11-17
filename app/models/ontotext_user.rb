module OntotextUser
  private
    def new_api_connexion
      Faraday.new(:url => 'https://api.datagraft.net') do |faraday|
        faraday.response :logger                  # log requests to STDOUT
        faraday.use :cookie_jar                   # yes we do use cookies
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
    end

    def register_ontotext_account
      return if has_ontotext_account

      account_token = rand(1..1000000).to_i

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
        throw "Fuck fuck fuck"
      end

      conn
    end

    def ontotext_connexion

      if has_ontotext_account
        conn = new_api_connexion
      else
        conn = register_ontotext_account
      end

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

      conn
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

      throw "lol" unless resp.status.between?(200, 299)

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

    def new_api_key
      "lol"
    end
end