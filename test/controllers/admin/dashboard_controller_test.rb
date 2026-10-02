require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "requires login" do
    get admin_root_url
    assert_redirected_to new_session_url
  end

  test "shows the restaurant and only its items grouped by category" do
    items(:taco).update!(available: false)
    sign_in_as users(:one)

    get admin_root_url
    assert_response :success
    assert_select "h1", restaurants(:one).name
    assert_select "##{ActionView::RecordIdentifier.dom_id(items(:taco))}", text: /Oculto/
    assert_select "[role=switch][aria-checked=false]", 1
    assert_select "##{ActionView::RecordIdentifier.dom_id(items(:soup))}", 0
  end

  test "shows an empty state without items" do
    sign_in_as users(:one)
    Item.where(category: restaurants(:one).categories).delete_all

    get admin_root_url
    assert_select "p", "Aún no tienes platillos"
  end
end
