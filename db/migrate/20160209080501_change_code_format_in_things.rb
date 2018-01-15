class ChangeCodeFormatInThings < ActiveRecord::Migration[4.2]
  def change
    remove_column :things, :code
    add_column :things, :configuration, :json
  end
end
