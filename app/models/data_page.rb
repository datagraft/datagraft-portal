class DataPage < Thing
  extend FriendlyId
  # friendly_id :name, use: => [:slugged, :simple_i18n]
  friendly_id :name, :use => [:history, :scoped], :scope => :user

  has_many :data_page_widgets
  has_many :widgets, :through => :data_page_widgets

  has_many :data_page_queriable_data_stores
  has_many :queriable_data_stores, :through => :data_page_queriable_data_stores
end
