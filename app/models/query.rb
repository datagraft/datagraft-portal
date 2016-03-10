class Query < Thing
  extend FriendlyId
  friendly_id :name, :use => [:history, :scoped], :scope => [:user, :type]

  validates_presence_of :query

  @@allowed_languages = %w(SPARQL SQL R whatever)
  cattr_accessor :allowed_languages

  validates :language, presence: true, inclusion: {in: @@allowed_languages}

  def should_generate_new_friendly_id?
    name_changed? || super
  end

  def query
    configuration["query"] unless configuration.blank?
  end

  def query=(val)
    touch_configuration!
    configuration["query"] = val
  end

  def language
    configuration["language"] unless configuration.blank?
  end

  def language=(val)
    touch_configuration!
    configuration["language"] = val
  end

end