class AddIsadminToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :isadmin, :boolean, :default => false
  end
end
