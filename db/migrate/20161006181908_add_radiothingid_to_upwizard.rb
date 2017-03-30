class AddRadiothingidToUpwizard < ActiveRecord::Migration[5.0]
  def change
    add_column :upwizards, :radio_thing_id, :integer
  end
end
