require "test_helper"

class RestaurantTest < ActiveSupport::TestCase
  test "slug is unique and accent-free" do
    restaurant = Restaurant.create!(name: "Taquería Uno", user: User.create!(email_address: "x@example.com", password: "Secreta123"))
    assert_equal "taqueria-uno-2", restaurant.slug
  end

  test "editing an item bumps the restaurant so the public menu cache expires" do
    restaurant = restaurants(:one)
    assert_changes -> { restaurant.reload.updated_at } do
      items(:taco).update!(available: false)
    end
  end
end
