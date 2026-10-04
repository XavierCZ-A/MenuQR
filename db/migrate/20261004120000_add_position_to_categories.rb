class AddPositionToCategories < ActiveRecord::Migration[8.1]
  def up
    add_column :categories, :position, :integer

    # Keep the current (alphabetical) order as the starting position.
    execute <<~SQL
      UPDATE categories SET position = (
        SELECT COUNT(*) FROM categories AS others
        WHERE others.restaurant_id = categories.restaurant_id AND others.name <= categories.name
      )
    SQL

    change_column_null :categories, :position, false
  end

  def down
    remove_column :categories, :position
  end
end
