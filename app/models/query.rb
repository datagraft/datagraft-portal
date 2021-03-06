class Query < Thing
  extend FriendlyId
  friendly_id :name, :use => [:history, :scoped], :scope => [:user, :type]

  has_many :queriable_data_store_queries, dependent: :destroy
  has_many :queriable_data_stores, :through => :queriable_data_store_queries

  has_many :sparql_endpoint_queries, dependent: :destroy
  has_many :sparql_endpoints, :through => :sparql_endpoint_queries
  has_many :arango_db_queries, dependent: :destroy
  has_many :arango_dbs, :through => :arango_db_queries

  validates_presence_of :query_string

  @@allowed_languages = %w(SPARQL AQL SQL R whatever)
  cattr_accessor :allowed_languages

  # No longer required for SPARQL endpoints
  #  validates :language, presence: true, inclusion: {in: @@allowed_languages}
  accepts_nested_attributes_for :queriable_data_stores
  accepts_nested_attributes_for :sparql_endpoints
  accepts_nested_attributes_for :arango_dbs


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


  # TO-BE-DELETED. Deprecated method no longer used? Commented out for now.
=begin
  def execute(sparql_endpoint, timeout = 180)
    if sparql_endpoint.has_rdf_repo?
      res = sparql_endpoint.rdf_repo.query_repository(query_string)
      return {
        headers: [],
        results: []
      } if res == nil

      query_res = JSON.parse(res.body)
      return {
        headers: query_res["head"]["vars"],
        results: query_res["results"]["bindings"]
      }
    else
      return {
        headers: [],
        results: []
      } if not sparql_endpoint.uri

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

      # update the metric for number of query executions
      increment_query_execution_metric(self)

      parsed = JSON.parse(result.body)

      return {
        headers: parsed["head"]["vars"],
        results: parsed["results"]["bindings"]
        }
    end
  end
=end

  # Execute query on SPARQL endpoint
  def execute_on_sparql_endpoint(sparql_endpoint, user, timeout = 180)
    if sparql_endpoint.has_rdf_repo?
      res = sparql_endpoint.rdf_repo.query_repository(query_string)

      query_res = JSON.parse(res.body)
      return {
        headers: query_res["head"]["vars"],
        results: query_res["results"]["bindings"]
      }
    else
      raise "Error SparqlEndpoint has no database"
    end
  end

  # Execute query on Arango DB
  def execute_on_arango_db(adb, user, timeout = 180)
    if adb.has_dbm?
      public = adb.user != user

      res = adb.dbm.query_database(adb.db_name, query_string, public)
      # Collect all headers from the first entry
      headers = []
      if res["result"].count > 0
        res["result"][0].each do |k,v|
          headers << k
        end
      end

      # Reformat the values into result_list["header_name"]["value"]
      result_list = []
      res["result"].each do |in_entry|
        out_entry = {}
        in_entry.each do |k,v|
          out_entry[k] = {"value" => v}
        end
        result_list << out_entry
      end
      return {
        headers: headers,
        results: result_list
      }

    else
      raise "Error ArangoDb has no database"
    end
  end
end
