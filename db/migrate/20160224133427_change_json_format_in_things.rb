class ChangeJsonFormatInThings < ActiveRecord::Migration[4.2]
  def up
    change_column :things, :metadata, :jsonb
    change_column :things, :configuration, :jsonb
  end

  def down
    change_column :things, :metadata, :json
    change_column :things, :configuration, :json
  end
end
