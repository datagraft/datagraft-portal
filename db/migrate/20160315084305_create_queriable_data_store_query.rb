class CreateQueriableDataStoreQuery < ActiveRecord::Migration[4.2]
  def change
    create_table :queriable_data_store_queries do |t|
      t.belongs_to :queriable_data_store, index: true
      t.belongs_to :query, index: true
      t.timestamps null: false
    end
  end
end
