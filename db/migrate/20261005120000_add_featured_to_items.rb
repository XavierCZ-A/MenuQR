class AddFeaturedToItems < ActiveRecord::Migration[8.1]
  def change
    add_column :items, :featured, :boolean, default: false, null: false
  end
end
