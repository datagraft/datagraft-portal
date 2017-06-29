class RemoveDbTypeFromDbAccounts < ActiveRecord::Migration[5.0]
  def change
    remove_column :db_accounts, :db_type, :string
  end
end
