class CatalogueRecord < ApplicationRecord
  belongs_to :catalogue
  belongs_to :thing
end
