class CreateSparqlEndpoints < ActiveRecord::Migration
  def change
    create_table :sparql_endpoints do |t|

      t.timestamps null: false
    end
  end
end
