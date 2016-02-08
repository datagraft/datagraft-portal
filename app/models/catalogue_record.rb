class CatalogueRecord < ActiveRecord::Base
  belongs_to :catalogue
  belongs_to :thing
end
