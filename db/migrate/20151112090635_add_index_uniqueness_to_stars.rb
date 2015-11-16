class AddIndexUniquenessToStars < ActiveRecord::Migration
  def change
    add_index :stars, [:user_id, :thing_id], :unique => true
  end
end
