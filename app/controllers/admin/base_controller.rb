class Admin::BaseController < ApplicationController
  layout "admin"

  helper_method :current_restaurant

  private
    def current_restaurant
      @current_restaurant ||= Current.user.restaurants.first!
    end
end
