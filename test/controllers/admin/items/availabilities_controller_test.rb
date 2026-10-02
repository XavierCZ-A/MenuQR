require "test_helper"

class Admin::Items::AvailabilitiesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "hides and shows an item" do
    delete admin_item_availability_url(items(:taco))
    assert_redirected_to admin_root_url
    assert_not items(:taco).reload.available?

    post admin_item_availability_url(items(:taco))
    assert items(:taco).reload.available?
  end

  test "cannot toggle another restaurant's item" do
    delete admin_item_availability_url(items(:soup))
    assert_response :not_found
    assert items(:soup).reload.available?
  end
end
