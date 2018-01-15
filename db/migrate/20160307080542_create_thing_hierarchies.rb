class CreateThingHierarchies < ActiveRecord::Migration[4.2]
  def change
    create_table :thing_hierarchies, id: false do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
    end

    add_index :thing_hierarchies, [:ancestor_id, :descendant_id, :generations],
      unique: true,
      name: "thing_anc_desc_idx"

    add_index :thing_hierarchies, [:descendant_id],
      name: "thing_desc_idx"
  end
end
