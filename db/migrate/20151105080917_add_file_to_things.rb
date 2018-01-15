class AddFileToThings < ActiveRecord::Migration[4.2]
  def change
    add_column :things, :file_id, :string
  end
end
