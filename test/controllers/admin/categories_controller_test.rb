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

  test "edit and create forms start hidden" do
    get admin_categories_url
    assert_select "form[data-inline-edit-target=edit]", count: 3
    assert_select "form[data-inline-edit-target=edit]:not([hidden])", count: 0
  end

  test "creates a category at the end of the list" do
    post admin_categories_url, params: { category: { name: " Postres " } }
    assert_redirected_to admin_categories_url

    category = restaurants(:one).categories.find_by!(name: "Postres")
    assert_equal restaurants(:one).categories.maximum(:position), category.position
  end

  test "shows the create form open with the error when the name is taken" do
    post admin_categories_url, params: { category: { name: "Bebidas" } }
    assert_response :unprocessable_content
    assert_select "form[action='#{admin_categories_path}']:not([hidden]) [role=alert]", text: "Nombre de la categoría ya está en uso"
  end

  test "renames a category" do
    patch admin_category_url(categories(:drinks_one)), params: { category: { name: "Bebidas frías" } }
    assert_redirected_to admin_categories_url
    assert_equal "Bebidas frías", categories(:drinks_one).reload.name
  end

  test "keeps the rename form open with the error when the name is blank" do
    patch admin_category_url(categories(:drinks_one)), params: { category: { name: " " } }
    assert_response :unprocessable_content
    assert_select "##{ActionView::RecordIdentifier.dom_id(categories(:drinks_one))} form:not([hidden]) [role=alert]"
    assert_equal "Bebidas", categories(:drinks_one).reload.name
  end

  test "deletes an empty category" do
    empty = restaurants(:one).categories.create!(name: "Postres")

    assert_difference "Category.count", -1 do
      delete admin_category_url(empty)
    end
    assert_redirected_to admin_categories_url
  end

  test "does not delete a category with items" do
    assert_no_difference "Category.count" do
      delete admin_category_url(categories(:drinks_one))
    end
    follow_redirect!
    assert_select "[role=alert]", text: /platillos relacionados/
  end

  test "does not delete the last category" do
    sign_in_as users(:two)
    items(:soup).destroy!

    assert_no_difference "Category.count" do
      delete admin_category_url(categories(:general_two))
    end
    follow_redirect!
    assert_select "[role=alert]", text: "Tu menú necesita al menos una categoría"
  end

  test "disables delete for categories with items" do
    restaurants(:one).categories.create!(name: "Postres")

    get admin_categories_url
    assert_select "button[aria-label='Eliminar General'][disabled]"
    assert_select "button[aria-label='Eliminar Postres']:not([disabled])"
  end

  test "cannot touch another restaurant's category" do
    patch admin_category_url(categories(:general_two)), params: { category: { name: "Hack" } }
    assert_response :not_found
    delete admin_category_url(categories(:general_two))
    assert_response :not_found
  end
end
