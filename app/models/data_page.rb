class DataPage < Thing
  extend FriendlyId
  # friendly_id :name, use: => [:slugged, :simple_i18n]
  friendly_id :name, :use => [:history, :scoped], :scope => :user

  # Relations
  has_many :data_page_widgets
  has_many :widgets, :through => :data_page_widgets

  has_many :data_page_queriable_data_stores
  has_many :queriable_data_stores, :through => :data_page_queriable_data_stores

  # store :metadata, accessors: [:description], coder: JSON

  # TODO check allow_destroy and cancancan
  accepts_nested_attributes_for :widgets, reject_if: :all_blank, :allow_destroy => true

  def license
    metadata["license"] if metadata
  end

  def license=(val)
    touch_metadata!
    metadata["license"] = val
  end
end
