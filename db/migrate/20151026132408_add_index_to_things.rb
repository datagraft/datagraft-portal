class AddIndexToThings < ActiveRecord::Migration[4.2]
  def change
    add_index "things", ["type"], name: "index_things_on_type", unique: false
  end
end
