class AddTransformedFileTypeToUpwizard < ActiveRecord::Migration[5.0]
  def change
    add_column :upwizards, :transformed_file_type, :string
  end
end
