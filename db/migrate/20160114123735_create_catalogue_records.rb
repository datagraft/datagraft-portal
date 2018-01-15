class CreateCatalogueRecords < ActiveRecord::Migration[4.2]
  def change
    create_table :catalogue_records do |t|
      t.integer :catalogue_id
      t.integer :thing_id

      t.timestamps null: false
    end
  end
end
