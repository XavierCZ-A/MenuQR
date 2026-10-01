class RestaurantsController < ApplicationController
  # GET /restaurants/1 or /restaurants/1.json
  def show
    @restaurant = Restaurant.find_by(slug: params[:slug])
  end

  # PATCH/PUT /restaurants/1 or /restaurants/1.json
  # def update
  #   respond_to do |format|
  #     if @restaurant.update(restaurant_params)
  #       format.html { redirect_to @restaurant, notice: "Restaurant was successfully updated.", status: :see_other }
  #       format.json { render :show, status: :ok, location: @restaurant }
  #     else
  #       format.html { render :edit, status: :unprocessable_content }
  #       format.json { render json: @restaurant.errors, status: :unprocessable_content }
  #     end
  #   end
  # end

  private
end
