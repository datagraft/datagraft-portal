class QueriableDataStore < Thing
  extend FriendlyId
  friendly_id :name, :use => [:history, :scoped], :scope => :user

  @@allowed_hosting_providers = %w(ontotext dandelion)
  cattr_accessor :allowed_hosting_providers

  validates :hosting_provider, presence: true, inclusion: {in: @@allowed_hosting_providers}
  validates :uri, url: {allow_blank: true}

  # validates :uri, presence: true, inclusion: {in: %w(canard lapin) }

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
