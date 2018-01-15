class CreateDbms2 < ActiveRecord::Migration[5.0]
  def change
    create_table :dbms do |t|
      t.string :type
      t.jsonb :configuration
      t.belongs_to :user, index: true

      t.timestamps
    end
  end
end
