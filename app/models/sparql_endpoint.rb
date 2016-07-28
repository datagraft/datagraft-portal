class SparqlEndpoint < Thing
  extend FriendlyId
  friendly_id :name, :use => [:history, :scoped], :scope => [:user, :type]

  def license
    metadata["license"] if metadata
  end

  def license=(val)
    touch_metadata!
    metadata["license"] = val
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

end
