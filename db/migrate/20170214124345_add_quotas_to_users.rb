class AddQuotasToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :quota_sparql_count, :integer, :default => 10
    add_column :users, :quota_sparql_ktriples, :integer, :default => 10240 ## 10*1024 ktriples
    add_column :users, :quota_transformation_count, :integer, :default => 100
    add_column :users, :quota_filestore_count, :integer, :default => 100
    add_column :users, :quota_filestore_ksize, :integer, :default => 1048576 ## 1024*1024 kbytes
  end
end
