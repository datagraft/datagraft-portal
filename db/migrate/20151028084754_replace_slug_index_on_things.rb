class ReplaceSlugIndexOnThings < ActiveRecord::Migration[4.2]
  def change
    remove_index :things, :slug
    add_index :things, [:slug, :user_id], :unique => true
  end
end
