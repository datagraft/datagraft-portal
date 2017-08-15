class RemoveWrongIdsForRdfRepo < ActiveRecord::Migration[5.0]
  def change
    remove_column :rdf_repos, :thing_id, :integer
  end
end
