class SparqlEndpoint < Thing
  extend FriendlyId
  friendly_id :name, :use => [:history, :scoped], :scope => [:user, :type]

  has_many :sparql_endpoint_queries, dependent: :destroy
  has_many :queries, :through => :sparql_endpoint_queries

  accepts_nested_attributes_for :queries, reject_if: :all_blank, :allow_destroy => true

  # Non-persistent attribute for storing query to be executed
  attr_accessor :execute_query
  attr_accessor :publish_file


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

  def cached_size
    result = nil
    result = metadata["cached_size"] if metadata
    return (result ||= '0')
  end

  def cached_size=(val)
    touch_metadata!
    metadata["cached_size"] = val ||= 0
  end

  def write_attribute(attr_name, value)
    # Check if new (no user) or update (existing user)
    if self.user != nil and attr_name == 'public'
      old_value = self.read_attribute(attr_name)
      super
      new_value = self.read_attribute(attr_name)

      # Update public/private property if changed
      if new_value != old_value
        self.user.update_ontotext_repository_public(self)
      end
    else
      super
    end
  end

end
