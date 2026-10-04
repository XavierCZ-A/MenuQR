require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = User.take }

  test "new" do
    get new_password_path
    assert_response :success
  end

  test "create" do
    post passwords_path, params: { email_address: @user.email_address }
    assert_enqueued_email_with PasswordsMailer, :reset, args: [ @user ]
    assert_redirected_to new_session_path

    follow_redirect!
    assert_notice "te enviamos las instrucciones"
  end

  test "create for an unknown user redirects but sends no mail" do
    post passwords_path, params: { email_address: "missing-user@example.com" }
    assert_enqueued_emails 0
    assert_redirected_to new_session_path

    follow_redirect!
    assert_notice "te enviamos las instrucciones"
  end

  test "edit" do
    get edit_password_path(@user.password_reset_token)
    assert_response :success
  end

  test "edit with invalid password reset token" do
    get edit_password_path("invalid token")
    assert_redirected_to new_password_path

    follow_redirect!
    assert_notice "no es válido o ya expiró"
  end

  test "update" do
    assert_changes -> { @user.reload.password_digest } do
      put password_path(@user.password_reset_token), params: { password: "NuevaClave1", password_confirmation: "NuevaClave1" }
      assert_redirected_to new_session_path
    end

    follow_redirect!
    assert_notice "Tu contraseña se actualizó"
  end

  test "update with non matching passwords" do
    token = @user.password_reset_token
    assert_no_changes -> { @user.reload.password_digest } do
      put password_path(token), params: { password: "NuevaClave1", password_confirmation: "OtraClave1" }
      assert_redirected_to edit_password_path(token)
    end

    follow_redirect!
    assert_notice "Las contraseñas no coinciden"
  end

  test "update with a weak password" do
    token = @user.password_reset_token
    assert_no_changes -> { @user.reload.password_digest } do
      put password_path(token), params: { password: "corta", password_confirmation: "corta" }
      assert_redirected_to edit_password_path(token)
    end

    follow_redirect!
    assert_notice "al menos 8 caracteres"
  end

  private
    def assert_notice(text)
      assert_select "[role=alert], [role=status]", /#{text}/
    end
end
