class AddParentIdToThings < ActiveRecord::Migration[4.2]
  def change
    add_column :things, :parent_id, :integer
  end
end
