class Query < Thing
  extend FriendlyId
  friendly_id :name, :use => [:history, :scoped], :scope => [:user, :type]

  has_many :queriable_data_store_queries
  has_many :queriable_data_stores, :through => :queriable_data_store_queries
  
  validates_presence_of :query

  @@allowed_languages = %w(SPARQL SQL R whatever)
  cattr_accessor :allowed_languages

  validates :language, presence: true, inclusion: {in: @@allowed_languages}
  accepts_nested_attributes_for :queriable_data_stores

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

  def language
    configuration["language"] unless configuration.blank?
  end

  def language=(val)
    touch_configuration!
    configuration["language"] = val
  end

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

end