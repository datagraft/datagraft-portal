class Query < Thing
  extend FriendlyId
  friendly_id :name, :use => [:history, :scoped], :scope => [:user, :type]

  has_many :queriable_data_store_queries, dependent: :destroy
  has_many :queriable_data_stores, :through => :queriable_data_store_queries

  has_many :sparql_endpoint_queries, dependent: :destroy
  has_many :sparql_endpoints, :through => :sparql_endpoint_queries

  validates_presence_of :query_string

  @@allowed_languages = %w(SPARQL SQL R whatever)
  cattr_accessor :allowed_languages

  # No longer required for SPARQL endpoints
  #  validates :language, presence: true, inclusion: {in: @@allowed_languages}
  accepts_nested_attributes_for :queriable_data_stores
  accepts_nested_attributes_for :sparql_endpoints


  def should_generate_new_friendly_id?
    name_changed? || super
  end


  def query_string
    configuration["query"] unless configuration.blank?
  end


  def query_string=(val)
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


  def execute(sparql_endpoint, timeout = 180)
    conn = Faraday.new(sparql_endpoint.uri) do |c|
      # c.response :json
      c.request :url_encoded
      c.adapter Faraday.default_adapter
    end

    result = conn.get do |req|
      req.params['query'] = query_string
      req.headers['Accept'] = 'application/sparql-results+json'#application/rdf+json'
      req.options.timeout = timeout
    end

    if result.status != 200
      raise result.body
    end

    parsed = JSON.parse(result.body)

    return {
      headers: parsed["head"]["vars"],
      results: parsed["results"]["bindings"]
      }
  end


  def execute_on_sparql_endpoint(sparql_endpoint, user, timeout = 180)
    return {
      headers: [],
      results: []
      } if not sparql_endpoint.uri

    conn = Faraday.new(sparql_endpoint.uri) do |c|
      c.request :url_encoded
      c.adapter Faraday.default_adapter
    end

    if !sparql_endpoint.public
      key = ApiKey.first_or_create(user)
      basicToken = Base64.strict_encode64(key.key)
      conn.authorization :Basic, basicToken
    end

    result = conn.get do |req|
      req.params['query'] = query_string
      req.headers['Accept'] = 'application/sparql-results+json'
      req.options.timeout = timeout
    end

    if result.status != 200
      puts "Unable to execute query. Error " + result.status.to_s + ". Response: " + result.body
      raise "Unable to execute query. Error " + result.status.to_s
    end

    parsed = JSON.parse(result.body)

    return {
      headers: parsed["head"]["vars"],
      results: parsed["results"]["bindings"]
      }
  end

end
