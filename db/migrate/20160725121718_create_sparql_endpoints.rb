class CreateSparqlEndpoints < ActiveRecord::Migration[4.2]
  def change
    create_table :sparql_endpoints do |t|

      t.timestamps null: false
    end
  end
end
