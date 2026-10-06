class CreateTags < ActiveRecord::Migration[8.1]
  DEFAULT_NAMES = [ "⭐ Recomendado", "✨ Nuevo", "🌶️ Picante", "🌱 Vegetariano" ]

  def up
    create_table :tags do |t|
      t.references :restaurant, null: false, foreign_key: true
      t.string :name, null: false
      t.timestamps
    end
    add_index :tags, [ :restaurant_id, :name ], unique: true

    create_table :item_tags do |t|
      t.references :item, null: false, foreign_key: true, index: false
      t.references :tag, null: false, foreign_key: true
      t.timestamps
    end
    add_index :item_tags, [ :item_id, :tag_id ], unique: true

    # Los restaurantes existentes arrancan con las mismas etiquetas que uno nuevo.
    DEFAULT_NAMES.each do |name|
      execute <<~SQL
        INSERT INTO tags (restaurant_id, name, created_at, updated_at)
        SELECT id, #{connection.quote(name)}, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP FROM restaurants
      SQL
    end
  end

  def down
    drop_table :item_tags
    drop_table :tags
  end
end
