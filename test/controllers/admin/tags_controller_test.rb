require "test_helper"

class Admin::TagsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "lists only the restaurant's tags with their item count" do
    items(:taco).tags = [ tags(:spicy_one) ]

    get admin_tags_url
    assert_response :success
    assert_select "li", count: 2
    assert_select "li##{ActionView::RecordIdentifier.dom_id(tags(:spicy_one))}", text: /1 platillo/
  end

  test "creates a tag" do
    assert_difference -> { restaurants(:one).tags.count } do
      post admin_tags_url, params: { tag: { name: " 🌾 Sin gluten " } }
    end
    assert_redirected_to admin_tags_url
    assert_equal "🌾 Sin gluten", restaurants(:one).tags.last.name
  end

  test "rejects a duplicate name" do
    assert_no_difference "Tag.count" do
      post admin_tags_url, params: { tag: { name: "🌶️ Picante" } }
    end
    assert_response :unprocessable_content
    assert_select "[role=alert]"
  end

  test "renames a tag and the public menu shows the new name" do
    items(:taco).tags = [ tags(:spicy_one) ]

    patch admin_tag_url(tags(:spicy_one)), params: { tag: { name: "🔥 Muy picante" } }
    assert_redirected_to admin_tags_url

    get public_menu_url(restaurants(:one))
    assert_select "article span", text: "🔥 Muy picante"
  end

  test "deleting a tag removes it from its items" do
    items(:taco).tags = [ tags(:spicy_one) ]

    delete admin_tag_url(tags(:spicy_one))
    assert_redirected_to admin_tags_url
    assert_empty items(:taco).reload.tags
  end

  test "cannot touch another restaurant's tag" do
    patch admin_tag_url(tags(:spicy_two)), params: { tag: { name: "Hack" } }
    assert_response :not_found
    assert_equal "🌶️ Picante", tags(:spicy_two).reload.name
  end
end
