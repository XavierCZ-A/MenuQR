class RestaurantsController < ApplicationController
  allow_unauthenticated_access only: :show

  def show
    @restaurant = Restaurant.find_by!(slug: MenuSubdomain.slug_for(request))
    # Items/categories touch the restaurant, so its updated_at versions the whole menu.
    fresh_when(@restaurant)

    @categories = @restaurant.categories
      .eager_load(:items)
      .where(items: { available: true })
      .order(:position, "items.name")
      .preload(items: { images_attachments: { blob: { variant_records: { image_attachment: :blob } } } })
  end
end
