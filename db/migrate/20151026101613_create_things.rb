class CreateThings < ActiveRecord::Migration
  def change
    create_table :things do |t|
      t.integer :user_id
      t.boolean :public
      t.integer :stars_count, default: 0
      t.string :name
      t.text :code
      t.string :type

      t.timestamps null: false
    end
  end
end
