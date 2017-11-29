class CreateArangoDbQueries < ActiveRecord::Migration[5.0]
  def change
    create_table :arango_db_queries do |t|
      t.belongs_to :query, index: true
      t.belongs_to :arango_db, index: true
      t.timestamps null: false
    end
  end
end
