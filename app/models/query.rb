class Query < Thing
  extend FriendlyId
  friendly_id :name, :use => [:history, :scoped], :scope => [:user, :type]

  has_many :queriable_data_store_queries
  has_many :queriable_data_stores, :through => :queriable_data_store_queries
  
  has_many :sparql_endpoint_queries
  has_many :sparql_endpoints, :through => :sparql_endpoint_queries
  
  validates_presence_of :query

  @@allowed_languages = %w(SPARQL SQL R whatever)
  cattr_accessor :allowed_languages

# No longer required for SPARQL endpoints
#  validates :language, presence: true, inclusion: {in: @@allowed_languages}
  accepts_nested_attributes_for :queriable_data_stores
  accepts_nested_attributes_for :sparql_endpoints

  def should_generate_new_friendly_id?
    name_changed? || super
  end

  def query
    configuration["query"] unless configuration.blank?
  end

  def query=(val)
    touch_configuration!
    configuration["query"] = val
  end

  def query_type
    configuration["query_type"] unless configuration.blank?
  end
  
  def query_type=(val)
    touch_configuration!
    configuration["query_type"] = val
  end
  
  def language
    configuration["language"] unless configuration.blank?
  end

  def language=(val)
    touch_configuration!
    configuration["language"] = val
  end

# Old execute method on queriable data stores replaced with sparql endpoints
=begin
  def execute(queriable_data_store)
    # HERE IS UGLY CODE LOL
    if language == 'SPARQL' && queriable_data_store.hosting_provider = 'ontotext'
      conn = Faraday.new(queriable_data_store.uri) do |c|
        # c.response :json
        c.request :url_encoded
        c.adapter Faraday.default_adapter
      end

      result = conn.get do |req|
        req.params['query'] = query
        req.headers['Accept'] = 'application/sparql-results+json'#application/rdf+json'
      end

      if result.status != 200
        raise result.body
      end

      parsed = JSON.parse(result.body)

      return {
        headers: parsed["head"]["vars"],
        results: parsed["results"]["bindings"]
      }
      # return result.body
      # throw result
    else 
      raise "Only SPARQL on Ontotext backend querying is supported"
    end
  end
=end
  
  def execute(sparql_endpoint)
    conn = Faraday.new(sparql_endpoint.uri) do |c|
      # c.response :json
      c.request :url_encoded
      c.adapter Faraday.default_adapter
    end
    result = conn.get do |req|
      req.params['query'] = query
      req.headers['Accept'] = 'application/sparql-results+json'#application/rdf+json'
    end

    if result.status != 200
      raise result.body
    end

    parsed = JSON.parse(result.body)
byebug
    return {
      headers: parsed["head"]["vars"],
      results: parsed["results"]["bindings"]
    }
  end
  
  def execute_on_sparql_endpoint(sparql_endpoint)
    return {
      headers: [],
      results: []
    } if not sparql_endpoint.uri
    conn = Faraday.new(sparql_endpoint.uri) do |c|
#    conn = Faraday.new("https://rdf.datagraft.net/4845348921/db/repositories/1512015698_graft-computed-transformation-4") do |c|
      c.request :url_encoded
      c.adapter Faraday.default_adapter
    end

    result = conn.get do |req|
      req.params['query'] = query
      req.headers['Accept'] = 'application/sparql-results+json'
    end
#byebug    
    if result.status != 200
      raise result.body
    end

    parsed = JSON.parse(result.body)

    return {
      headers: parsed["head"]["vars"],
      results: parsed["results"]["bindings"]
    }    
  end

end
