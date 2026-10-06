require "test_helper"

class LandingControllerTest < ActionDispatch::IntegrationTest
  test "shows landing to visitors" do
    get root_path
    assert_response :success
    assert_select "a[href=?]", new_user_path
  end

  test "sends signed in users to the dashboard" do
    sign_in_as users(:one)
    get root_path
    assert_redirected_to admin_root_path
  end
end
