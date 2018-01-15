class CreateStars < ActiveRecord::Migration[4.2]
  def change
    create_table :stars do |t|
      t.integer :user_id
      t.integer :thing_id

      t.timestamps null: false
    end
    add_index :stars, :user_id
  end
end
