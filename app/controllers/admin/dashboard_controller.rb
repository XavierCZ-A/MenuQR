class Admin::DashboardController < Admin::BaseController
  def show
    @categories = current_restaurant.categories
      .eager_load(:items)
      .order(:name, "items.name")
      .preload(items: { images_attachments: { blob: { variant_records: { image_attachment: :blob } } } })
      .select { |category| category.items.any? }

    @items = @categories.flat_map(&:items)
  end
end
