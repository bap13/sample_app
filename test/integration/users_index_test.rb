require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:brett)
    @other_user = users(:fox)
  end

  test "index including pagination" do
    log_in_as(@user)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    User.paginate(page: 1).each do |user|
      assert_select "a[href=?]", user_path(user), text: user.name
    end
  end

  test "test index page as admin and delete link" do
    log_in_as(@user)
    get users_path
    User.paginate(page: 1).each do |user|
      unless user == @user
        assert_select "a[href=?]", user_path(user), text: 'delete',
                                                    method: :delete
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@other_user)
    end
  end

  test "test index page as non-admin" do
    log_in_as(@other_user)
    get users_path
    assert_select "a", text: 'delete', count: 0
  end
end
