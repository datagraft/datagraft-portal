class AddFileToThings < ActiveRecord::Migration
  def change
    add_column :things, :file_id, :string
  end
end
