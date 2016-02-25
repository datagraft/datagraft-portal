class Catalogue < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, :use => :history
  belongs_to :user
  has_many :catalogue_stars
  has_many :things, :through => :catalogue_records
  
  validates :name, presence: true
  
  has_paper_trail
  
  def self.public_list
    Catalogue.where(:public => true).order(stars_count: :desc, created_at: :desc).includes(:user)
  end

  def self.public_search(search)
    # ActiveRecord::Base.connection.execute("SELECT set_limit(0.1);")
    # self.public_list.fuzzy_search(name: search)
    self.public_list.basic_search(name: search)
  end
end
