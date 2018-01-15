class AddMetadataToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :website, :string
    add_column :users, :name, :string
    add_column :users, :organization, :string
    add_column :users, :place, :string
  end
end
