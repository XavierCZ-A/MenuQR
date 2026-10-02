# frozen_string_literal: true

module Navbar
  class Component < ViewComponent::Base
    attr_reader :restaurant

    def initialize(restaurant:)
      super()

      @restaurant = restaurant
    end

    def menu_url
      helpers.restaurant_url(restaurant.slug)
    end
  end
end
