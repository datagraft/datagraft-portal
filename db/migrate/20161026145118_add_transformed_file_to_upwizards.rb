class AddTransformedFileToUpwizards < ActiveRecord::Migration[5.0]
  def change
    add_column :upwizards, :transformed_file_id, :string
    add_column :upwizards, :transformed_file_size, :integer
  end
end
