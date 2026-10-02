class Admin::DashboardController < Admin::BaseController
  def show
    @categories = current_restaurant.categories
      .eager_load(:items)
      .order(:name, "items.name")
      .select { |category| category.items.any? }

    @items = @categories.flat_map(&:items)
  end
end
