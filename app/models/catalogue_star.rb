class CatalogueStar < ApplicationRecord
  belongs_to :user
  belongs_to :catalogue, counter_cache: :stars_count
  
  validates_presence_of :user 
  validates_presence_of :catalogue 

  validates_uniqueness_of :user, :scope => :catalogue_id
end
