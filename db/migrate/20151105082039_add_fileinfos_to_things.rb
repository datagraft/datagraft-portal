class AddFileinfosToThings < ActiveRecord::Migration
  def change
    add_column :things, :file_size, :integer
    add_column :things, :file_content_type, :string
  end
end
