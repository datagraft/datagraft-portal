class Filestore < Thing
  extend FriendlyId
  # friendly_id :name, use: => [:slugged, :simple_i18n]
  friendly_id :name, :use => [:history, :scoped], :scope => [:user, :type]

  attachment :file

  def should_generate_new_friendly_id?
    name_changed? || super
  end
  
  def keywords
    if metadata.blank? 
      ret = Array.new
    else
      ret = metadata['keyword'] 
    end
  end

  def keywords=(keyw_array)
    touch_metadata!
    metadata['keyword'] = keyw_array
  end
  
  def separator
    if metadata.blank? 
      ret = Array.new
    else
      ret = metadata['csv_separator'] 
      if ret.blank?
        ret = "COMMA"
      end
    end
    ret # Assure that ret is returned
  end

  def separator=(sep_char)
    touch_metadata!
    metadata['csv_separator'] = sep_char
  end
  
end
