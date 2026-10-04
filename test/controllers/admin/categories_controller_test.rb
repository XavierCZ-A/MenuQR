require "test_helper"

class Admin::CategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:one)
    Item.create!(name: "Horchata", price: "30", category: categories(:drinks_one), images: [ dish_image ])
  end

  test "lists categories in order, flagging empty ones" do
    restaurants(:one).categories.create!(name: "Postres")

    get admin_categories_url
    assert_response :success
    assert_select "[data-sortable-target=list] li p.font-medium", count: 3 do |names|
      assert_equal %w[ General Bebidas Postres ], names.map { it.text.strip }
    end
    assert_select "li", text: /no aparece en el menú/, count: 1
    assert_select "[data-sortable-target=preview] span", count: 2
  end

  test "saves the new order and the public menu follows it" do
    patch order_admin_categories_url, params: { category_ids: [ categories(:drinks_one).id, categories(:general_one).id ] }, as: :json
    assert_response :no_content

    get restaurant_url(restaurants(:one).slug)
    assert_select "[data-menu-tabs-target=tab]" do |tabs|
      assert_equal %w[ Bebidas General ], tabs.map(&:text)
    end
  end

  test "ignores other restaurants' categories" do
    patch order_admin_categories_url, params: { category_ids: [ categories(:general_two).id, categories(:general_one).id ] }, as: :json
    assert_response :no_content
    assert_equal 1, categories(:general_two).reload.position
    assert_equal 2, categories(:general_one).reload.position
  end

  test "dashboard links to the sort page when there are several categories" do
    get admin_root_url
    assert_select "a[href=?]", admin_categories_path
  end
end
