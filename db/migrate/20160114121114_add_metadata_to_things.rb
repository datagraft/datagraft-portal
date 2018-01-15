class AddMetadataToThings < ActiveRecord::Migration[4.2]
  def change
    add_column :things, :metadata, :json
  end
end
