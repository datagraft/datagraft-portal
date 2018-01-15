class CreateDbAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :db_accounts do |t|
      t.references :user, foreign_key: true
      t.string :db_type
      t.jsonb :configuration

      t.timestamps
    end
  end
end
