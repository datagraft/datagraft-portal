class DataDistribution < Thing
  extend FriendlyId
  # friendly_id :name, use: => [:slugged, :simple_i18n]
  friendly_id :name, :use => [:history, :scoped], :scope => [:user, :type]

  attachment :file

  def should_generate_new_friendly_id?
    name_changed? || super
  end
end
