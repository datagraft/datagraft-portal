class AddRdfRepoIdToThings < ActiveRecord::Migration[5.0]
  def change
    add_column :things, :rdf_repo_id, :integer
  end
end
