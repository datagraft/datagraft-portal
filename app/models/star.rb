class Star < ActiveRecord::Base
  # belongs_to :asset, counter_cache: true
  belongs_to :user
  belongs_to :bordel, counter_cache: true
end
