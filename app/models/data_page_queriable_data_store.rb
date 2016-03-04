class DataPageQueriableDataStore < ApplicationRecord
  belongs_to :data_page
  belongs_to :queriable_data_store
end
