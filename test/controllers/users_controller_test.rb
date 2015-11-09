require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  def setup
    @user = users(:brett)
    @different_user = users(:fox)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should redirect edit when not logged in" do
    get :edit, id: @user
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    patch :edit, id: @user, user: { name: @user.name, email: @user.email }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect edit when logged in as wrong user" do
    log_in_as(@different_user)
    get :edit, id: @user
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect update when logged in a wrong user" do
    log_in_as(@different_user)
    patch :edit, id: @user, user: { name: @user.name, email: @user.email }
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "should not allow the admin attribute to be edited via the web" do
    log_in_as(@different_user)
    assert_not @different_user.admin?
    patch :update, id: @different_user, user: { password: 'spooky',
                                            password_confirmation: 'spooky',
                                            admin: true }
    assert_not @different_user.reload.admin?
  end

  test "should redirect index when not logged in" do
    get :index
    assert_redirected_to login_url
  end

  test "index page should not display inactive users" do
    log_in_as(@user)
    @different_user.toggle!(:activated)
    get :index
    assert_select "a", text: @different_user.name, count: 0
  end

  test "show page should redirect when user is inactive" do
    @user.toggle!(:activated)
    get :show, id: @user
    assert_redirected_to root_url
  end

  test "should redirect destroy when not logged in" do
    assert_no_difference 'User.count' do
      delete :destroy, id: @user
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy when logged in as a non-admin" do
    log_in_as(@different_user)
    assert_no_difference 'User.count' do
      delete :destroy, id: @user
    end
    assert_redirected_to root_url
  end

  test "should redirect following when not logged in" do
    get :followers, id: @user
    assert_redirected_to login_url
  end

  test "should redirect followers when not logged in" do
    get :following, id: @user
    assert_redirected_to login_url
  end
end
