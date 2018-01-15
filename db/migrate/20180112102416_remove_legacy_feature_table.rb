class RemoveLegacyFeatureTable < ActiveRecord::Migration[5.1]
  def change
    drop_table :features, if_exists: true
  end
end
