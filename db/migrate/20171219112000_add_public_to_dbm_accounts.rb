class AddPublicToDbmAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :dbm_accounts, :public,  :boolean, default: false
  end
end
