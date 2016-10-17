class AddRedirectstepToUpwizard < ActiveRecord::Migration[5.0]
  def change
    add_column :upwizards, :redirect_step, :string
  end
end
