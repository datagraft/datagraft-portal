class SetDefaultCatalogueNumberOfStars < ActiveRecord::Migration
  def change
    change_column :catalogues, :stars_count, :integer, default: 0
  end
end
