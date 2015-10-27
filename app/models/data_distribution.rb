class DataDistribution < Thing
  extend FriendlyId
  friendly_id :name, use: => [:slugged, :simple_i18n]
end
