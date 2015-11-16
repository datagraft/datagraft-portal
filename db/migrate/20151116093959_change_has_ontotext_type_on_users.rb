class ChangeHasOntotextTypeOnUsers < ActiveRecord::Migration
  def change
    remove_column :users, :has_ontotext_account
    add_column :users, :ontotext_account, :integer, default: 0
  end
end
