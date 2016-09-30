class CreateFileWizards < ActiveRecord::Migration[5.0]
  def change
    create_table :file_wizards do |t|

      t.timestamps
    end
  end
end
