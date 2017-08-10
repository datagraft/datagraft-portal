class RevertDbAccountSetup < ActiveRecord::Migration[5.0]
  def change
    remove_column :things, :db_account_id, :integer
    drop_table :db_keys
    drop_table :db_accounts
  end
end
