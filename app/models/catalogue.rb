class Catalogue < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, :use => :history
  belongs_to :user
  has_many :catalogue_stars
  has_many :things, :through => :catalogue_records
  
  validates :name, presence: true
  
  has_paper_trail
end
