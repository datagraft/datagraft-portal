class FixTreeStatesBooleans < ActiveRecord::Migration[4.2]
  def up
    change_column :api_keys,   :enabled, :boolean, null: false, default: false
    change_column :things,     :public,  :boolean, null: false, default: false
    change_column :catalogues, :public,  :boolean, null: false, default: false
  end

  def down
    change_column :api_keys,   :enabled, :boolean
    change_column :things,     :public,  :boolean
    change_column :catalogues, :public,  :boolean
  end
end
