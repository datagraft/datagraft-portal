class AddDbmIdToApiKeys < ActiveRecord::Migration[5.0]
  def change
    add_column :api_keys, :dbm_id, :integer
  end
end
