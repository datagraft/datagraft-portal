class AddMetadataToUsers < ActiveRecord::Migration
  def change
    add_column :users, :website, :string
    add_column :users, :name, :string
    add_column :users, :organization, :string
    add_column :users, :place, :string
  end
end
