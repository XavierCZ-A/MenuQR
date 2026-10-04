class Admin::CategoriesController < Admin::BaseController
  def index
    @categories = current_restaurant.categories.left_joins(:items).group(:id).order(:position)
      .select("categories.*, COUNT(items.id) AS items_count")
  end

  # Receives every category id in the new order (sent by the sortable list).
  def update_order
    ids = params.expect(category_ids: []).map(&:to_i)
    categories = current_restaurant.categories.where(id: ids).index_by(&:id)

    Category.transaction do
      ids.each.with_index(1) { |id, position| categories[id]&.update!(position: position) }
    end

    head :no_content
  end
end
