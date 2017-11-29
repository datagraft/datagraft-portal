class ArangoDbQuery < ApplicationRecord
  belongs_to :query
  belongs_to :arango_db
end
