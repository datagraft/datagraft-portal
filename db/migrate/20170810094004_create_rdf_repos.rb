class CreateRdfRepos < ActiveRecord::Migration[5.0]
  def change
    create_table :rdf_repos do |t|
      t.references :thing, foreign_key: true
      t.jsonb :configuration
      t.belongs_to :dbm, index: true

      t.timestamps
    end
  end
end
