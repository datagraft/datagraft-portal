class AddIndexToThings < ActiveRecord::Migration
  def change
    add_index "things", ["type"], name: "index_things_on_type", unique: false
  end
end
