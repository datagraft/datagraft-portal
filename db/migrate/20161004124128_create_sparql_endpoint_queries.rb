class CreateSparqlEndpointQueries < ActiveRecord::Migration[5.0]
  def change
    create_table :sparql_endpoint_queries do |t|
      t.belongs_to :query, index: true
      t.belongs_to :sparql_endpoint, index: true
      t.timestamps null: false
    end
  end
end
