class CreateCatalogueStars < ActiveRecord::Migration
  def change
    create_table :catalogue_stars do |t|
      t.integer :user_id
      t.integer :catalogue_id

      t.timestamps null: false
    end
    add_index :catalogue_stars, :user_id
  end
end
