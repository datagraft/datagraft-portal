class AddTaskToUpwizard < ActiveRecord::Migration[5.0]
  def change
    add_column :upwizards, :task, :string
  end
end
