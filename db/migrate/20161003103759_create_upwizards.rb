class CreateUpwizards < ActiveRecord::Migration[5.0]
  def change
    create_table :upwizards do |t|

      t.timestamps
    end
  end
end
