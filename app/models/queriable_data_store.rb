class QueriableDataStore < Thing
  extend FriendlyId
  friendly_id :name, :use => [:history, :scoped], :scope => [:user, :type]

  @@allowed_hosting_providers = %w(ontotext dandelion)
  cattr_accessor :allowed_hosting_providers

  validates :hosting_provider, presence: true, inclusion: {in: @@allowed_hosting_providers}
  validates :uri, url: {allow_blank: true}
  validate :lock_uri_when_updated

  has_many :queriable_data_store_queries
  has_many :queries, :through => :queriable_data_store_queries

  has_many :data_page_queriable_data_stores
  has_many :data_pages, :through => :data_page_queriable_data_stores 

  accepts_nested_attributes_for :queries, reject_if: :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :data_pages

  def fork(newuser)
    self.deep_clone include: {queriable_data_store_queries: :query} do |original, copy|
      if copy.instance_of?(QueriableDataStore) || copy.instance_of?(::Query)
        copy.user = newuser
        copy.stars_count = 0
        copy.public = false
        original.add_child copy
      end
    end
  end

  def should_generate_new_friendly_id?
    name_changed? || super
  end

  def uri
    metadata["uri"] if metadata
  end

  def uri=(val)
    touch_metadata!
    attribute_will_change!('uri') if uri != val
    metadata["uri"] = val
  end

  def hosting_provider
    metadata["hosting_provider"] if metadata
  end

  def hosting_provider=(val)
    touch_metadata!
    metadata["hosting_provider"] = val
  end

  private

  def lock_uri_when_updated
    unless self.new_record?
      errors.add(:uri, "The URI must not be changed") if changed.include?('uri')
    end
  end

end
