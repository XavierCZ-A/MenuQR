class PublishRestaurantsByDefault < ActiveRecord::Migration[8.1]
  def up
    # Hasta ahora published no se usaba y todos los menús estaban visibles; se mantienen así.
    execute "UPDATE restaurants SET published = TRUE"
    change_column :restaurants, :published, :boolean, default: true, null: false
  end

  def down
    change_column :restaurants, :published, :boolean, default: false, null: true
  end
end
