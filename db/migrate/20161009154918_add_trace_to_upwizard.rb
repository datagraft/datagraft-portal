class AddTraceToUpwizard < ActiveRecord::Migration[5.0]
  def change
    add_column :upwizards, :trace, :jsonb
  end
end
