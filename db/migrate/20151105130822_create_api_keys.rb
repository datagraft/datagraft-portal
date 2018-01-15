class CreateApiKeys < ActiveRecord::Migration[4.2]
  def change
    create_table :api_keys do |t|
      t.integer :user_id
      t.boolean :enabled
      t.string :name
      t.string :key

      t.timestamps null: false
    end
    add_index :api_keys, :key
  end
end
