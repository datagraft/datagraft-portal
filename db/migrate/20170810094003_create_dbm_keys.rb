class CreateDbmKeys < ActiveRecord::Migration[5.0]
  def change
    create_table :dbm_keys do |t|
      t.boolean :enabled
      t.string :name
      t.string :key
      t.belongs_to :dbm, index: true

      t.timestamps
    end
  end
end
