class AddFieldsToItems < ActiveRecord::Migration[8.1]
  def change
    add_column :items, :name, :string, null: false
    add_column :items, :description, :text
    add_column :items, :price_cents, :integer, null: false
    add_column :items, :available, :boolean, default: true
  end
end
