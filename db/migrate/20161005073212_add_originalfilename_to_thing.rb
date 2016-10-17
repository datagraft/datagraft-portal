class AddOriginalfilenameToThing < ActiveRecord::Migration[5.0]
  def change
    add_column :things, :original_filename, :string
  end
end
