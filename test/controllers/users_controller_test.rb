require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "registers a user with their restaurant and signs them in" do
    assert_difference [ "User.count", "Restaurant.count" ], 1 do
      post users_url, params: { user: {
        email_address: "nuevo@example.com", password: "Secreta123",
        restaurants_attributes: { "0" => { name: "Café Ñandú" } }
      } }
    end

    assert_redirected_to admin_root_url
    restaurant = User.find_by!(email_address: "nuevo@example.com").restaurants.sole
    assert_equal "cafe-nandu", restaurant.slug
    assert_equal [ Category::DEFAULT_NAME ], restaurant.categories.pluck(:name)
  end

  test "rejects a weak password" do
    assert_no_difference "User.count" do
      post users_url, params: { user: {
        email_address: "nuevo@example.com", password: "corta",
        restaurants_attributes: { "0" => { name: "Café" } }
      } }
    end

    assert_response :unprocessable_entity
  end
end
