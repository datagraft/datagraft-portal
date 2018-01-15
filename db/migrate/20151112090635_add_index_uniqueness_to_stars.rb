class AddIndexUniquenessToStars < ActiveRecord::Migration[4.2]
  def change
    add_index :stars, [:user_id, :thing_id], :unique => true
  end
end
