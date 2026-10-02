require "test_helper"

class RestaurantsControllerTest < ActionDispatch::IntegrationTest
  test "public menu shows only available items without login" do
    items(:taco).update!(available: false)
    Item.create!(name: "Horchata", price: "30", category: categories(:drinks_one), images: [ dish_image ])

    get restaurant_url(restaurants(:one).slug)

    assert_response :success
    assert_select "h1", restaurants(:one).name
    assert_select "article h3", text: "Horchata"
    assert_select "article img[alt=Horchata][loading=lazy]"
    assert_select "article h3", text: "Taco al pastor", count: 0
  end

  test "hides tabs when only one category has items" do
    get restaurant_url(restaurants(:one).slug)
    assert_select "nav[aria-label='Categorías del menú']", 0
  end

  test "shows a tab per category with items" do
    Item.create!(name: "Horchata", price: "30", category: categories(:drinks_one), images: [ dish_image ])

    get restaurant_url(restaurants(:one).slug)
    assert_select "[data-menu-tabs-target=tab]", 2
  end

  test "header shows logo, banner, hours and address" do
    restaurants(:one).update!(logo: dish_image, banner: dish_image, hours: "13:00 a 23:00", address: "Roma Norte")

    get restaurant_url(restaurants(:one).slug)
    assert_select "header img", 2
    assert_select "header li", text: "13:00 a 23:00"
    assert_select "header li", text: "Roma Norte"
  end

  test "unknown slug is not found" do
    get restaurant_url("no-existe")
    assert_response :not_found
  end
end
