class AddMetadataToThings < ActiveRecord::Migration
  def change
    add_column :things, :metadata, :json
  end
end
