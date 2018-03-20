class CreateDataPageQueriableDataStores < ActiveRecord::Migration[4.2]
  def change
    create_table :data_page_queriable_data_stores do |t|
      t.belongs_to :data_page, index: true
      t.belongs_to :queriable_data_store, index: {name: 'index_datapages_queriable_data_stores'}
      t.timestamps null: false
    end
  end
end
