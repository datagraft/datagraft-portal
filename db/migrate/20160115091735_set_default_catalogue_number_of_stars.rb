class SetDefaultCatalogueNumberOfStars < ActiveRecord::Migration[4.2]
  def change
    change_column :catalogues, :stars_count, :integer, default: 0
  end
end
