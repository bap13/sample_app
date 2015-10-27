require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  test "invalid form should not create a new user" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, user: { name: "",
                               email: "user@invalid",
                               password: "foo",
                               password_confirmation: "bar" }
    end
    assert_template 'users/new'
  end

  test "valid form should create a new user" do
    get signup_path
    assert_difference 'User.count', 1 do
      post_via_redirect users_path, user: { name: "Valid Username",
                                            email: "valid@example.com",
                                            password: "foobar",
                                            password_confirmation: "foobar" }
    end
    assert_template 'users/show'
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
    assert_template 'users/show'
    assert_not flash.empty?
  end
end
