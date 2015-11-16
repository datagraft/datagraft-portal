class AddHasOntotextAccountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :has_ontotext_account, :boolean
  end
end
