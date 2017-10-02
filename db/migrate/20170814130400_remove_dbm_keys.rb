class RemoveDbmKeys < ActiveRecord::Migration[5.0]
  def change
    drop_table :dbm_keys
  end
end
