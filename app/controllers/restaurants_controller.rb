class RestaurantsController < ApplicationController
  allow_unauthenticated_access only: :show

  def show
    @restaurant = Restaurant.find_by(slug: MenuSubdomain.slug_for(request))
    return render :not_found, status: :not_found unless @restaurant
    return render :unpublished, status: :not_found unless @restaurant.published?
    # Items/categories touch the restaurant, so its updated_at versions the whole menu.
    fresh_when(@restaurant)

    @categories = @restaurant.categories
      .eager_load(:items)
      .where(items: { available: true })
      .order(:position, "items.featured DESC", "items.name")
      .preload(items: [ :tags, images_attachments: { blob: { variant_records: { image_attachment: :blob } } } ])
  end
end
