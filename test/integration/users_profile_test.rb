require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  def setup
    @user = users(:brett)
  end

  test "profile display" do
    get user_path(@user)
    assert_template 'users/show'
    assert_select 'title', full_title(@user.name)
    # User stats
    assert_select 'h1', text: @user.name
    assert_select 'a.profile-photo>img.gravatar'
    assert_select 'img[alt = ?]', @user.name
    # Following/followers stats
    assert_select 'a[href=?]', following_user_path(@user)
    assert_select 'a[href=?]', followers_user_path(@user)
    assert_select '#following', @user.following.count.to_s
    assert_select '#followers', @user.followers.count.to_s
    # Microposts feed
    assert_match @user.microposts.count.to_s, response.body
    assert_select 'div.pagination'
    @user.microposts.paginate(page: 1).each do |micropost|
      assert_match micropost.content, response.body
    end
  end
end
