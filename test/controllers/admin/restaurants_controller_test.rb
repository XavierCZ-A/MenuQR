require "test_helper"

class Admin::RestaurantsControllerTest < ActionDispatch::IntegrationTest
  setup { @restaurant = restaurants(:one) }

  test "requires login" do
    get edit_admin_restaurant_url
    assert_redirected_to new_session_url
  end

  test "edits only the current user's restaurant" do
    sign_in_as users(:one)

    get edit_admin_restaurant_url
    assert_response :success
    assert_select "input[name='restaurant[name]'][value=?]", @restaurant.name
  end

  test "updates info and images" do
    sign_in_as users(:one)

    patch admin_restaurant_url, params: { restaurant: {
      name: "Taquería Nueva", description: "  Tacos de canasta ", address: "Roma Norte", hours: "13:00 a 23:00",
      logo: dish_image("dish.png"), banner: dish_image
    } }

    assert_redirected_to edit_admin_restaurant_url
    @restaurant.reload
    assert_equal [ "Taquería Nueva", "Tacos de canasta", "Roma Norte", "13:00 a 23:00" ],
      [ @restaurant.name, @restaurant.description, @restaurant.address, @restaurant.hours ]
    assert @restaurant.logo.attached?
    assert @restaurant.banner.attached?
    assert_equal "taqueria-uno", @restaurant.slug, "el enlace del QR no debe cambiar"
  end

  test "removes a flagged image unless a new one is uploaded" do
    @restaurant.update!(logo: dish_image, banner: dish_image)
    sign_in_as users(:one)

    patch admin_restaurant_url, params: { restaurant: { remove_logo: "1", remove_banner: "1", banner: dish_image("dish.png") } }

    @restaurant.reload
    assert_not @restaurant.logo.attached?
    assert_equal "image/png", @restaurant.banner.content_type
  end

  test "keeps images when nothing is uploaded" do
    @restaurant.update!(logo: dish_image)
    sign_in_as users(:one)

    patch admin_restaurant_url, params: { restaurant: { name: "Otro nombre", remove_logo: "0" } }
    assert @restaurant.reload.logo.attached?
  end

  test "rejects invalid data" do
    sign_in_as users(:one)

    patch admin_restaurant_url, params: { restaurant: {
      name: " ", logo: fixture_file_upload("notes.txt")
    } }

    assert_response :unprocessable_content
    assert_select "[role=alert] li", 2
    assert_select "nav", text: /#{@restaurant.name}/
    assert_equal "Taquería Uno", @restaurant.reload.name
  end
end
