class IndexThingsOnUserId < ActiveRecord::Migration[4.2]
  def change
    add_index "things", ["user_id"], name: "index_things_on_user_id", unique: false
  end
end
