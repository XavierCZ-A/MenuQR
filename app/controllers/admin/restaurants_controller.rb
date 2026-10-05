class Admin::RestaurantsController < Admin::BaseController
  # Copia aparte de current_restaurant: si la validación falla, el navbar no muestra datos sin guardar.
  before_action :set_restaurant

  def edit
  end

  def update
    if @restaurant.update(restaurant_params)
      redirect_to edit_admin_restaurant_path, notice: "Cambios guardados."
    else
      render :edit, status: :unprocessable_content
    end
  end

  private
    def set_restaurant
      @restaurant = Current.user.restaurants.find(current_restaurant.id)
    end

    def restaurant_params
      params.expect(restaurant: [ :name, :description, :address, :hours, :logo, :banner, :remove_logo, :remove_banner, :published ])
    end
end
