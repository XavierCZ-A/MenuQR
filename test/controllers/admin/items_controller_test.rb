require "test_helper"

class Admin::ItemsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "new preselects the General category" do
    get new_admin_item_url
    assert_response :success
    assert_select "select[name='item[category_id]'] option[selected]", text: "General"
  end

  test "creates an item in the selected category" do
    assert_difference("Item.count") do
      post admin_items_url, params: { item: { name: "Horchata", price: "35.00", category_id: categories(:drinks_one).id } }
    end

    assert_redirected_to admin_items_url
    item = Item.last
    assert_equal 3500, item.price_cents
    assert_equal categories(:drinks_one), item.category
  end

  test "creates a new category from the form" do
    assert_difference([ "Item.count", "Category.count" ]) do
      post admin_items_url, params: { item: { name: "Flan", price: "50", category_id: categories(:general_one).id, new_category_name: " Postres " } }
    end

    assert_equal "Postres", Item.last.category.name
    assert_equal restaurants(:one), Item.last.category.restaurant
  end

  test "reuses an existing category with the same name" do
    assert_no_difference("Category.count") do
      post admin_items_url, params: { item: { name: "Agua", price: "20", new_category_name: "Bebidas" } }
    end

    assert_equal categories(:drinks_one), Item.last.category
  end

  test "does not keep a new category when the item is invalid" do
    assert_no_difference([ "Item.count", "Category.count" ]) do
      post admin_items_url, params: { item: { name: "", price: "50", new_category_name: "Postres" } }
    end

    assert_response :unprocessable_content
  end

  test "rejects a category from another restaurant" do
    assert_no_difference("Item.count") do
      post admin_items_url, params: { item: { name: "Taco", price: "20", category_id: categories(:general_two).id } }
    end

    assert_response :unprocessable_content
  end

  test "cannot edit another restaurant's item" do
    get edit_admin_item_url(items(:soup))
    assert_response :not_found
  end

  test "updates an item" do
    patch admin_item_url(items(:taco)), params: { item: { name: "Taco de suadero", price: "28", category_id: categories(:general_one).id } }

    assert_redirected_to admin_items_url
    assert_equal 2800, items(:taco).reload.price_cents
  end
end
