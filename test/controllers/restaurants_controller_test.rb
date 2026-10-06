require "test_helper"

class RestaurantsControllerTest < ActionDispatch::IntegrationTest
  test "public menu shows only available items without login" do
    items(:taco).update!(available: false)
    Item.create!(name: "Horchata", price: "30", category: categories(:drinks_one), images: [ dish_image ])

    get public_menu_url(restaurants(:one))

    assert_response :success
    assert_select "h1", restaurants(:one).name
    assert_select "article h3", text: "Horchata"
    assert_select "article img[alt=Horchata][loading=lazy]"
    assert_select "article h3", text: "Taco al pastor", count: 0
  end

  test "hides tabs when only one category has items" do
    get public_menu_url(restaurants(:one))
    assert_select "nav[aria-label='Categorías del menú']", 0
  end

  test "shows a tab per category with items" do
    Item.create!(name: "Horchata", price: "30", category: categories(:drinks_one), images: [ dish_image ])

    get public_menu_url(restaurants(:one))
    assert_select "[data-menu-tabs-target=tab]", 2
  end

  test "header shows logo, banner, hours and address" do
    restaurants(:one).update!(logo: dish_image, banner: dish_image, hours: "13:00 a 23:00", address: "Roma Norte")

    get public_menu_url(restaurants(:one))
    assert_select "header img", 2
    assert_select "header li", text: "13:00 a 23:00"
    assert_select "header li", text: "Roma Norte"
  end

  test "answers 304 when the menu has not changed" do
    get public_menu_url(restaurants(:one))
    get public_menu_url(restaurants(:one)), headers: { "If-None-Match" => response.etag }
    assert_response :not_modified
  end

  test "shares the banner as Open Graph image" do
    restaurants(:one).update!(banner: dish_image, description: "Tacos de la casa")

    get public_menu_url(restaurants(:one))
    assert_select "meta[property='og:title'][content=?]", restaurants(:one).name
    assert_select "meta[property='og:description'][content=?]", "Tacos de la casa"
    assert_select "meta[property='og:image'][content^=http]"
  end

  test "unknown slug is not found" do
    get "http://no-existe.localhost/"
    assert_response :not_found
    assert_select "h1", "No encontramos este menú"
  end

  test "unpublished menu shows it is unavailable" do
    restaurants(:one).update!(published: false)

    get public_menu_url(restaurants(:one))
    assert_response :not_found
    assert_select "h1", "Menú no disponible por ahora"
  end

  test "the menu is served from the restaurant subdomain" do
    assert_equal "http://taqueria-uno.localhost/", public_menu_url(restaurants(:one))
  end

  test "reserved subdomains and the bare domain do not serve a menu" do
    %w[ http://www.localhost/ http://localhost/ ].each do |url|
      get url
      assert_select "h1", "Tu menú con código QR, listo en minutos"
    end
  end

  test "menu subdomains only serve the menu" do
    %w[ /login /register /dashboard /dashboard/settings /passwords/new ].each do |path|
      get "http://taqueria-uno.localhost#{path}"
      assert_response :not_found, path
    end
  end

  test "menu images still load from the subdomain" do
    restaurants(:one).update!(logo: dish_image)

    get public_menu_url(restaurants(:one))
    src = css_select("header img").first["src"]
    assert_match %r{\Ahttp://taqueria-uno\.localhost/rails/active_storage/}, src
    get src
    assert_response :redirect
  end

  test "the old path-based menu URL is gone" do
    get "/restaurants/taqueria-uno"
    assert_response :not_found
  end
end
