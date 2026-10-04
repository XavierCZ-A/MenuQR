require "test_helper"

class Admin::QrCodesControllerTest < ActionDispatch::IntegrationTest
  test "requires login" do
    get admin_qr_code_url(format: :png)
    assert_redirected_to new_session_url
  end

  test "renders the menu QR as SVG and PNG" do
    sign_in_as users(:one)

    get admin_qr_code_url(format: :svg)
    assert_response :success
    assert_equal "image/svg+xml", response.media_type
    assert_includes response.body, "<svg"

    get admin_qr_code_url(format: :png)
    assert_response :success
    assert_equal "image/png", response.media_type
    assert_match(/attachment; filename="menu-#{restaurants(:one).slug}.png"/, response.headers["Content-Disposition"])
  end

  test "answers 304 for an unchanged QR" do
    sign_in_as users(:one)

    get admin_qr_code_url(format: :svg)
    get admin_qr_code_url(format: :svg), headers: { "If-None-Match" => response.etag }
    assert_response :not_modified
  end
end
