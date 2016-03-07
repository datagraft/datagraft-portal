class AddParentIdToThings < ActiveRecord::Migration
  def change
    add_column :things, :parent_id, :integer
  end
end
