class AddDbmIdToThings < ActiveRecord::Migration[5.0]
  def change
    add_column :things, :dbm_id, :integer
  end
end
