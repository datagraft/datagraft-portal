class AddCurrentFileTypeToUpwizard < ActiveRecord::Migration[5.0]
  def change
    add_column :upwizards, :current_file_type, :string
  end
end
