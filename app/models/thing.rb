class Thing < ApplicationRecord
  extend FriendlyId
  # friendly_id :name, :use => [:slugged, :simple_i18n, :history]
  # friendly_id :name, use: => [:slugged, :simple_i18n, :history, :scoped], :scope => :user
  # friendly_id :name, :use => [:history, :scoped], :scope => :user
  friendly_id :name, :use => :history

  has_many :stars
  has_many :catalogues, :through => :catalogue_records
  belongs_to :user

  validates :name, presence: true

  has_paper_trail


  def self.public_list
    Thing.where(:public => true, :type => ['DataPage', 'Transformation'])
         .order(stars_count: :desc, created_at: :desc).includes(:user)
  end

  def self.public_search(search)
    # ActiveRecord::Base.connection.execute("SELECT set_limit(0.1);")
    self.public_list
         .basic_search({name: search, metadata: search}, false)
         # .fuzzy_search(name: search)
  end

  def has_metadata?(key)
    !get_metadata(key).nil?
  end

  def get_metadata(key)
    Rodash.get(metadata, key)
  end
end

class Query < Thing; end
class Widget < Thing; end
# class UtilityFunction < Thing;
