class IndexThingsOnUserId < ActiveRecord::Migration
  def change
    add_index "things", ["user_id"], name: "index_things_on_user_id", unique: false
  end
end
