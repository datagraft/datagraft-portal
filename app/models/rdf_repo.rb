class RdfRepo < ApplicationRecord
  belongs_to :dbm
  has_many :things
end
