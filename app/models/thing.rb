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

  # As parents and children (forking stuff)
  has_closure_tree

  # Versionning
  has_paper_trail


  def self.public_list
    Thing.where(:public => true, :type => ['DataPage', 'Transformation', 'DataDistribution'])
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
    # throw metadata
    Rodash.get(metadata, key)
  end

  def description
    metadata["description"] if metadata
  end

  def description=(val)
    touch_metadata!
    metadata["description"] = val
  end

  def has_children?
    return !self.children.empty?
  end

  protected
    def touch_metadata!
      self.metadata = {} if not metadata
    end

    def touch_configuration!
      self.configuration = {} if not configuration
    end 
end

# class Query < Thing; end
# class Widget < Thing; end
# class UtilityFunction < Thing;
