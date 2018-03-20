class AddEnabledToDbmAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :dbm_accounts, :enabled, :boolean
  end
end
