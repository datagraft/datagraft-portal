class SparqlEndpoint < Thing
  extend FriendlyId
  friendly_id :name, :use => [:history, :scoped], :scope => [:user, :type]

  has_many :sparql_endpoint_queries
  has_many :queries, :through => :sparql_endpoint_queries

  accepts_nested_attributes_for :queries, reject_if: :all_blank, :allow_destroy => true

  # Non-persistent attribute for storing query to be executed
  attr_accessor :execute_query

  def should_generate_new_friendly_id?
    name_changed? || super
  end

  def license
    metadata["license"] if metadata
  end

  def license=(val)
    touch_metadata!
    metadata["license"] = val
  end

  def uri
    metadata["uri"] if metadata
  end

  def uri=(val)
    touch_metadata!
    attribute_will_change!('uri') if uri != val
    metadata["uri"] = val
  end

end
