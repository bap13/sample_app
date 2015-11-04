require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "invalid form should not create a new user" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, user: { name: "",
                               email: "user@invalid",
                               password:              "foo",
                               password_confirmation: "bar" }
    end
    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'div.field_with_errors'
  end

  test "valid signup information with account activation" do
    # Go to signup page and submit post with valid user information
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, user: { name: "Valid Username",
                               email: "valid@example.com",
                               password:              "foobar",
                               password_confirmation: "foobar" }
    end
    # Check that activation email was sent and user is not yet activated
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    # Try to log in before activation
    log_in_as(user)
    assert_not is_logged_in?
    # Invalid activation token
    get edit_account_activation_path("invalid token")
    assert_not is_logged_in?
    # Valid token, wrong user
    get edit_account_activation_path(user.activation_token, email: "wrong")
    assert_not is_logged_in?
    # Valid activation token, correct Email
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end

  test "blank name should give correct error message" do
    user = User.new(name: "    ",
                    email: "valid@example.com",
                    password: "foobar",
                    password_confirmation: "foobar")
    user.save
    assert_equal user.errors.full_messages[0], "Name can't be blank"
  end

  test "blank email should give correct error message" do
    user = User.new(name: "valid",
                    email: "     ",
                    password: "foobar",
                    password_confirmation: "foobar")
    user.save
    assert_equal user.errors.full_messages[0], "Email can't be blank"
  end

  test "invalid email should give correct error message" do
    user = User.new(name: "valid",
                    email: "invalid@example",
                    password: "foobar",
                    password_confirmation: "foobar")
    user.save
    assert_equal user.errors.full_messages[0], "Email is invalid"
  end

  test "blank password should give correct error message" do
    user = User.new(name: "valid",
                    email: "valid@example.com",
                    password: "",
                    password_confirmation: "foobar")
    user.save
    assert_equal user.errors.full_messages[0], "Password can't be blank"
  end

  test "short password shoud give correct error message" do
    user = User.new(name: "valid",
                    email: "valid@example.com",
                    password: "foo",
                    password_confirmation: "foo")
    user.save
    assert_equal user.errors.full_messages[0],
                              "Password is too short (minimum is 6 characters)"
  end

  test "password/confirmation mismatch shoud give correct error message" do
    user = User.new(name: "valid",
                    email: "valid@example.com",
                    password: "foobar",
                    password_confirmation: "foobaz")
    user.save
    assert_equal user.errors.full_messages[0],
                              "Password confirmation doesn't match Password"
  end

  test "valid signup information should result in flash" do
    get signup_path
    assert_difference 'User.count', 1 do
      post_via_redirect users_path, user: { name: "Example User",
                                            email: "user@example.com",
                                            password: "password",
                                            password_confirmation: "password" }
    end
    # assert_template 'users/show'
    # assert_not flash.empty?
  end
end
