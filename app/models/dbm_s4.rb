# For test development purposes, assign the following environment variables
# *************************************************************************
# ENV['S4_DBM_ACCOUNT_NAME']
# ENV['S4_DBM_ACCOUNT_ENCRYPTED_PASSWORD']
# ENV['S4_DBM_API_ENDPOINT']
# ENV['S4_DBM_API_KEY_KEY1']
# ENV['S4_DBM_API_KEY_SECRET1']

class DbmS4 < Dbm
  private
    
  # Create Faraday RESTful API connection
  def new_api_connection
    Faraday.new(:url => 'https://api.datagraft.net') do |faraday|
      faraday.request :multipart
      faraday.request :url_encoded

      faraday.response :logger                  # log requests to STDOUT
      faraday.use :cookie_jar                   # yes we do use cookies
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end
    
  # Create an Ontotext S4 API connection
  def database_connection(use_api_key = true)
    conn = new_api_connection
    
    if use_api_key
      key = ENV['S4_DBM_API_KEY_KEY1']+':'+ENV['S4_DBM_API_KEY_SECRET1']
      basicToken = Base64.strict_encode64(key)
      conn.authorization :Basic, basicToken      
    else
      resp = conn.put do |req|
        req.url ENV['S4_DBM_API_ENDPOINT']
        req.headers['Content-Type'] = 'application/json'
      end
      
      throw self.ontotext_account unless resp.status.between?(200, 299)
    end
    
    conn  
  end
    
  
  public

  # Create a new S4 repository
  # curl -X PUT -H "Content-Type:application/json" -d "{\"repositoryID\" : \"test_repo_3\", \"label\" : \"Just a repo description.\", \"ruleset\" : \"owl-horst-optimized\",\"base-URL\" : \"http://example.org/graphdb#\"}" http://s4dsviqmqrg5:6vc2u1r1pjpp3f5@awseb-e-q-AWSEBLoa-1F3R7SVGQAWRO-1629925049.eu-west-1.elb.amazonaws.com:8080/4038446398/brian_test_db/repositories
  def create_repository()
    begin
      pname = qds[:name].parameterize
      today = Time.now.to_s.slice(0,10)

      connect = ontotext_connection_s4
      
      resp_dataset = connect.post do |req|
        req.url ENV['ONTOTEXT_S4_DATABASE_ENDPOINT']+'/repositories'
        req.headers['Content-Type'] = 'application/ld+json'
        req.body = {
          '@context' => ontotext_declaration,
          'dct:title' => qds[:name].parameterize,
          'dct:description' => qds[:description].to_s,
          'dcat:public' => qds[:public].to_s,
          'dct:modified'=> today,
          'dct:issued' => today
          }.to_json
      end
    end
  end

  def upload_file_to_repository(db_repository, file, file_type)
  end
  
  def query_repository(db_repository, query_string)
  end

  # Get the size of the S4 repository
  def get_repository_size(db_repository)
    begin
      return '0' if not se.uri

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
      se.cached_size = resp_size.body ||= se.cached_size
      se.save

      return resp_size.body

    end
    
  end
  
  # Set the public setting of the S4 repository
  # curl -X POST http://awseb-e-q-awsebloa-1f3r7svgqawro-1629925049.eu-west-1.elb.amazonaws.com:8080/4037539600/<db_name>/repositories/<repo_name>
  # -H 'Authorization: Basic czQ3N2diM3EzcG51OjNsNzk2NTBpZXFoZGw'
  # -H 'Cache-Control: no-cache'
  # -H 'Content-type: application/json' -d '{ "public": "false" }'
  def set_repository_public(db_repository)
  end

  # Delete an existing S4 repository
  # curl -X DELETE -H "Content-Type:application/json" http://s4dsviqmqrg5:6vc2u1r1pjpp3f5@awseb-e-q-AWSEBLoa-1F3R7SVGQAWRO-1629925049.eu-west-1.elb.amazonaws.com:8080/4038446398/brian_test_db/repositories/test_repo_3
  def delete_repository(db_repository)
    conn = s4_connection(true)    
  end

  @@supported_repository_types = %w(RDF)
end
