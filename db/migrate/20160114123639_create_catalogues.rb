class CreateCatalogues < ActiveRecord::Migration
  def change
    create_table :catalogues do |t|
      t.references :user, index: true, foreign_key: true
      t.string :name
      t.boolean :public
      t.integer :stars_count
      t.string :slug

      t.timestamps null: false
    end
    add_index :catalogues, :slug
  end
end
