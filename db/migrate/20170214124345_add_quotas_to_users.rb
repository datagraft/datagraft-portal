class AddQuotasToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :quota_sparql_count, :integer, :default => 10
    add_column :users, :quota_sparql_triples, :integer, :limit => 8, :default => 10485760 ## 10*1024*1024
    add_column :users, :quota_transformation_count, :integer, :default => 100
    add_column :users, :quota_filestore_count, :integer, :default => 100
    add_column :users, :quota_filestore_size, :integer, :limit => 8, :default => 1073741824 ## 1024*1024*1024
  end
end
