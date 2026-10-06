require "test_helper"

class LegalControllerTest < ActionDispatch::IntegrationTest
  test "privacy is public" do
    get privacy_path
    assert_response :success
    assert_select "h1", "Aviso de Privacidad Integral"
  end

  test "terms is public" do
    get terms_path
    assert_response :success
    assert_select "h1", "Términos de Servicio"
  end

  test "login links to legal pages" do
    get new_session_path
    assert_select "a[href=?]", privacy_path
    assert_select "a[href=?]", terms_path
  end
end
