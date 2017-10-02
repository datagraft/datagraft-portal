class CreateDbKeys < ActiveRecord::Migration[5.0]
  def change
    create_table :db_keys do |t|
      t.references :db_account, foreign_key: true
      t.boolean :enabled, default: false, null: false
      t.string :name
      t.string :key

      t.timestamps
    end
  end
end
