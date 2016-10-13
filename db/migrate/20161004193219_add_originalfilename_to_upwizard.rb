class AddOriginalfilenameToUpwizard < ActiveRecord::Migration[5.0]
  def change
    add_column :upwizards, :original_filename, :string
  end
end
