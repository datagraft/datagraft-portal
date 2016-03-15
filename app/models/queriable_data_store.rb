class QueriableDataStore < Thing
  extend FriendlyId
  friendly_id :name, :use => [:history, :scoped], :scope => [:user, :type]

  @@allowed_hosting_providers = %w(ontotext dandelion)
  cattr_accessor :allowed_hosting_providers

  validates :hosting_provider, presence: true, inclusion: {in: @@allowed_hosting_providers}
  validates :uri, url: {allow_blank: false}, presence: true

  has_many :queriable_data_store_queries
  has_many :queries, :through => :queriable_data_store_queries
  # validates :uri, presence: true, inclusion: {in: %w(canard lapin) }

  accepts_nested_attributes_for :queries, reject_if: :all_blank, :allow_destroy => true
  
  def should_generate_new_friendly_id?
    name_changed? || super
  end

  def uri
    metadata["uri"] if metadata
  end

  def uri=(val)
    touch_metadata!
    metadata["uri"] = val
  end

  def hosting_provider
    metadata["hosting_provider"] if metadata
  end

  def hosting_provider=(val)
    touch_metadata!
    metadata["hosting_provider"] = val
  end
end
