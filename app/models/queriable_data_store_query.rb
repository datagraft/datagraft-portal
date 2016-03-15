class QueriableDataStoreQuery < ApplicationRecord
  belongs_to :queriable_data_store
  belongs_to :query
end
