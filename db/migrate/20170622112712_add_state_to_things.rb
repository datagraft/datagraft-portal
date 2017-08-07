class AddStateToThings < ActiveRecord::Migration[5.0]
  def change
    add_column :things, :state, :string, default: 'repo_created'
  end
end
