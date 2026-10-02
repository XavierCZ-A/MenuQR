class AddCategoryToItems < ActiveRecord::Migration[8.1]
  def up
    add_reference :items, :category, null: false, foreign_key: true

    # Every restaurant gets a "General" category for menus without sections
    execute <<~SQL
      INSERT INTO categories (name, restaurant_id, created_at, updated_at)
      SELECT 'General', id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP FROM restaurants
      WHERE NOT EXISTS (
        SELECT 1 FROM categories WHERE categories.restaurant_id = restaurants.id AND categories.name = 'General'
      )
    SQL
  end

  def down
    remove_reference :items, :category, foreign_key: true
  end
end
