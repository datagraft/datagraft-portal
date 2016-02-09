class ChangeCodeFormatInThings < ActiveRecord::Migration
  def change
    remove_column :things, :code
    add_column :things, :configuration, :json
  end
end
