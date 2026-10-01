class CreateRestaurants < ActiveRecord::Migration[8.1]
  def change
    create_table :restaurants do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.string :currency, default: "MXN"
      t.boolean :published, default: false

      t.timestamps
    end
  end
end
