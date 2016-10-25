class AddFileidToUpwizard < ActiveRecord::Migration[5.0]
  def change
    add_column :upwizards, :file_id, :string
  end
end
