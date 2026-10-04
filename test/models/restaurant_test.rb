require "test_helper"

class RestaurantTest < ActiveSupport::TestCase
  test "slug is unique and accent-free" do
    restaurant = Restaurant.create!(name: "Taquería Uno", user: User.create!(email_address: "x@example.com", password: "Secreta123"))
    assert_equal "taqueria-uno-2", restaurant.slug
  end

  test "slug skips reserved subdomains" do
    restaurant = Restaurant.create!(name: "WWW", user: User.create!(email_address: "w@example.com", password: "Secreta123"))
    assert_equal "www-2", restaurant.slug
  end

  test "slug falls back when the name has no latin characters" do
    restaurant = Restaurant.create!(name: "寿司", user: User.create!(email_address: "s@example.com", password: "Secreta123"))
    assert_equal "restaurante", restaurant.slug
  end

  test "editing an item bumps the restaurant so the public menu cache expires" do
    restaurant = restaurants(:one)
    assert_changes -> { restaurant.reload.updated_at } do
      items(:taco).update!(available: false)
    end
  end
end
