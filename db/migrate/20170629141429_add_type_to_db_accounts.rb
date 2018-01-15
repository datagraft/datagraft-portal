class AddTypeToDbAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :db_accounts, :type, :string
  end
end
