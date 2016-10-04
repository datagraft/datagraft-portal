class AddFileinfoToUpwizard < ActiveRecord::Migration[5.0]
  def change
    add_column :upwizards, :file_size, :integer
    add_column :upwizards, :file_content_type, :string
  end
end
