class AddUseridToUpwizard < ActiveRecord::Migration[5.0]
  def change
    add_column :upwizards, :user_id, :integer
  end
end
