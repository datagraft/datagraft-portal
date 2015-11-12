class Star < ActiveRecord::Base
  # belongs_to :asset, counter_cache: true
  belongs_to :user
  belongs_to :thing, counter_cache: true

  validates_presence_of :user 
  validates_presence_of :thing 

  validates_uniqueness_of :user, :scope => :thing_id
end
