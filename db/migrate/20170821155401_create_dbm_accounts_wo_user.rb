class CreateDbmAccountsWoUser < ActiveRecord::Migration[5.0]
  def change
    create_table :dbm_accounts do |t|
      t.string :name
      t.string :encrypted_password
      t.belongs_to :dbm, index: true
      t.timestamps
    end
  end
end
