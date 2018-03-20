class AddHasOntotextAccountToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :has_ontotext_account, :boolean
  end
end
