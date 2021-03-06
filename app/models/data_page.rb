class DataPage < Thing
  extend FriendlyId
  # friendly_id :name, use: => [:slugged, :simple_i18n]
  friendly_id :name, :use => [:history, :scoped], :scope => [:user, :type]

  # Relations
  has_many :data_page_widgets
  has_many :widgets, :through => :data_page_widgets, dependent: :destroy

  has_many :data_page_queriable_data_stores
  has_many :queriable_data_stores, :through => :data_page_queriable_data_stores

  has_many :data_page_queries
  has_many :queries, :through => :data_page_queries

  # store :metadata, accessors: [:description], coder: JSON

  # TODO check allow_destroy and cancancan
  accepts_nested_attributes_for :widgets, reject_if: :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :queriable_data_stores

  def should_generate_new_friendly_id?
    name_changed? || super
  end

  def fork(newuser)
    self.deep_clone include: {data_page_widgets: :widget, data_page_queriable_data_stores: {queriable_data_store: {queriable_data_store_queries: :query}}} do |original, copy|
      if copy.instance_of?(DataPage) || copy.instance_of?(QueriableDataStore) || copy.instance_of?(Widget) || copy.instance_of?(::Query)
        copy.user = newuser
        copy.stars_count = 0
        copy.public = false
        original.add_child copy
      # elsif copy.instance_of? DataPageQueriableDataStore
      # elsif copy.instance_of? QueriableDataStoreQuery
      # elsif copy.instance_of? DataPageWidget
      # else
      #  throw ::Query
      #  throw copy.instance_of?(Query).to_s
      end
    end
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
