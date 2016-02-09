class FixeSlugIndex < ActiveRecord::Migration
  def change
    remove_index :things, [:slug, :user_id]
    add_index :things, [:slug, :user_id, :type], :unique => true
  end
end
