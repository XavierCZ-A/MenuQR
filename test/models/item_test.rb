require "test_helper"

class ItemTest < ActiveSupport::TestCase
  test "price converts to and from cents" do
    item = Item.new(price: "45.50")
    assert_equal 4550, item.price_cents
    assert_equal 45.5, item.price
  end

  test "requires a positive price" do
    item = Item.new(name: "Agua", category: categories(:general_one), price: "0")
    assert_not item.valid?
    assert item.errors.of_kind?(:price_cents, :greater_than)
  end

  test "new restaurants get a default category" do
    restaurant = Restaurant.create!(name: "Nuevo", user: User.create!(email_address: "new@example.com", password: "Secret123"))
    assert_equal [ Category::DEFAULT_NAME ], restaurant.categories.pluck(:name)
  end
end
