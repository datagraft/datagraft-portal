class SparqlEndpoint < Thing
  extend FriendlyId
  friendly_id :name, :use => [:history, :scoped], :scope => [:user, :type]

  acts_as_taggable_on :keywords
  
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
  
  def size
    if self.user.nil?
      0
    else
      1
#    user = self.find(:user)
#      user = self.user
#      user.send(get_ontotext_repository_size(@thing.uri))
    end
  end
  
end
