class SparqlEndpoint < Thing
  extend FriendlyId
  friendly_id :name, :use => [:history, :scoped], :scope => [:user, :type]

  acts_as_taggable_on :tags
  
  def should_generate_new_friendly_id?
    name_changed? || super
  end

  def keywords
    if metadata.blank? 
      ret = Array.new
    else
      ret = metadata['keyword'] 
    end
    return ret
  end

  def keywords=(keyw_array)
    touch_metadata!
    #When the array is returned from the form it comes in JSON format
    metadata['keyword'] = JSON.parse keyw_array
  end

  def license
    metadata["license"] if metadata
  end

  def license=(val)
    touch_metadata!
    metadata["license"] = val
  end

end
