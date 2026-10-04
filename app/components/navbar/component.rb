# frozen_string_literal: true

module Navbar
  class Component < ViewComponent::Base
    attr_reader :restaurant

    def initialize(restaurant:)
      super()

      @restaurant = restaurant
    end

    def menu_url
      helpers.public_menu_url(restaurant)
    end
  end
end
