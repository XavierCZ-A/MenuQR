require "test_helper"

class Admin::AccountsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:one) }

  test "requires login" do
    get edit_admin_account_url
    assert_redirected_to new_session_url
  end

  test "changes email with the current password" do
    sign_in_as @user

    patch admin_account_url, params: { current_password: "password", user: { email_address: " Nuevo@Example.com " } }

    assert_redirected_to edit_admin_account_url
    assert_equal "nuevo@example.com", @user.reload.email_address
  end

  test "rejects changes with a wrong current password" do
    sign_in_as @user

    patch admin_account_url, params: { current_password: "wrong", user: { email_address: "nuevo@example.com" } }

    assert_response :unprocessable_content
    assert_select "[role=alert]", text: /contraseña actual es incorrecta/
    assert_equal "one@example.com", @user.reload.email_address
  end

  test "changes password and closes other sessions" do
    other_session = @user.sessions.create!
    sign_in_as @user

    patch admin_account_url, params: { current_password: "password", user: { password: "NuevaClave1" } }

    assert_redirected_to edit_admin_account_url
    assert @user.reload.authenticate("NuevaClave1")
    assert_not Session.exists?(other_session.id)
    assert Session.exists?(Current.session.id)
  end

  test "rejects a weak new password" do
    sign_in_as @user

    patch admin_account_url, params: { current_password: "password", user: { password: "short" } }

    assert_response :unprocessable_content
    assert @user.reload.authenticate("password")
  end

  test "deletes the account with its restaurant, menu and images" do
    restaurants(:one).update!(logo: dish_image)
    sign_in_as @user

    assert_difference -> { User.count } => -1, -> { Restaurant.count } => -1, -> { Item.count } => -restaurants(:one).items.count do
      delete admin_account_url, params: { current_password: "password" }
    end

    assert_redirected_to root_url
    get admin_root_url
    assert_redirected_to new_session_url
  end

  test "does not delete the account with a wrong password" do
    sign_in_as @user

    assert_no_difference "User.count" do
      delete admin_account_url, params: { current_password: "wrong" }
    end
    assert_response :unprocessable_content
  end
end
