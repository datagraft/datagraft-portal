class CreateDataPageWidgets < ActiveRecord::Migration
  def change
    create_table :data_page_widgets do |t|
      t.belongs_to :data_page, index: true
      t.belongs_to :widget, index: true
      t.timestamps null: false
    end
  end
end
