class CreateCatalogueRecords < ActiveRecord::Migration
  def change
    create_table :catalogue_records do |t|
      t.integer :catalogue_id
      t.integer :thing_id

      t.timestamps null: false
    end
  end
end
