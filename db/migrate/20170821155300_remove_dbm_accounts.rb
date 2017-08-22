class RemoveDbmAccounts < ActiveRecord::Migration[5.0]
  def change
    drop_table :dbm_accounts
  end
end
