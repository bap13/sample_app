require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:brett)
  end

  test "forgot password" do
    # Visit 'forgot password' page
    get new_password_reset_path
    assert_template 'password_resets/new'
    # Submit invalid email address
    post password_resets_path, password_reset: { email: "invalid" }
    # Assert that the flash appears and the new password reset template
    # is rendered
    assert_not flash.empty?
    assert_template 'password_resets/new'
    # Submit valid email address
    post password_resets_path, password_reset: { email: @user.email }
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    # Check that an email was sent and user is redirected to root url
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url

    # Test password reset form
    user = assigns(:user)
    # Wrong Email
    get edit_password_reset_path(user.reset_token, email: "")
    assert_redirected_to root_url
    # Inactive user
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
    user.toggle!(:activated)
    # Right email; Wrong token
    get edit_password_reset_path("wrong token", email: user.email)
    assert_redirected_to root_url
    # Right email; Right token
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", user.email
    # Invalid password & confirmation
    patch password_reset_path(user.reset_token),
          email: user.email,
          user: { password:              "foobar",
                  password_confirmation: "barquux" }
    assert_select 'div#error_explanation'
    # Blank password
    patch password_reset_path(user.reset_token),
          email: user.email,
          user: { password:              "    ",
                  password_confirmation: "barquux" }
    assert_not flash.empty?
    assert_template 'password_resets/edit'
    # Valid password and confirmation
    patch password_reset_path(user.reset_token),
          email: user.email,
          user: { password:              "foobar",
                  password_confirmation: "foobar" }
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to user
  end
end
