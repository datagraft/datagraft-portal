class DataPage < Thing
  extend FriendlyId
  # friendly_id :name, use: => [:slugged, :simple_i18n]
  friendly_id :name, :use => [:history, :scoped], :scope => [:user, :type]

  # Relations
  has_many :data_page_widgets
  has_many :widgets, :through => :data_page_widgets

  has_many :data_page_queriable_data_stores
  has_many :queriable_data_stores, :through => :data_page_queriable_data_stores

  # store :metadata, accessors: [:description], coder: JSON

  # TODO check allow_destroy and cancancan
  accepts_nested_attributes_for :widgets, reject_if: :all_blank, :allow_destroy => true

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

  def layout(as_json=true)

    if not metadata
      return nil
    elsif as_json
      return JSON.generate(metadata["datagraft-layout"]) rescue nil
    else
      return metadata["datagraft-layout"]
    end

  end

  def layout=(val)
    touch_metadata!
    
    if val.is_a? String
      val = JSON.parse(val) rescue val
    end
     
    metadata["datagraft-layout"] = val
  end

end
