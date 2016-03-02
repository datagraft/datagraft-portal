class ChangeJsonFormatInThings < ActiveRecord::Migration
  def up
    change_column :things, :metadata, :jsonb
    change_column :things, :configuration, :jsonb
  end

  def down
    change_column :things, :metadata, :json
    change_column :things, :configuration, :json
  end
end
