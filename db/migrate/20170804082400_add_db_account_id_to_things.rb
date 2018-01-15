class AddDbAccountIdToThings < ActiveRecord::Migration[5.0]
  def change
    add_column :things, :db_account_id, :integer
  end
end
