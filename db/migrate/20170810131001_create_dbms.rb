class CreateDbms < ActiveRecord::Migration[5.0]
  def change
    create_table :dbms do |t|
      t.string :type
      t.jsonb :configuration

      t.timestamps
    end
  end
end
