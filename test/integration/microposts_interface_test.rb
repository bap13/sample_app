require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:brett)
    @other_user = users(:user_1)
  end

  test "micropost interface" do
    log_in_as(@user)
    get root_path
    assert_select 'div.pagination'
    assert_select 'input[type=file]'
    # Invalid submission
    assert_no_difference 'Micropost.count' do
      post microposts_path, micropost: { content: ""}
    end
    assert_select 'div#error_explanation'
    # Valid submission
    content = "This is valid content for a micropost."
    picture = fixture_file_upload('test/fixtures/rails.png', 'image/png')
    assert_difference 'Micropost.count', 1 do
      post microposts_path, micropost: { content: content }
    end
    assert_difference 'Micropost.count', 1 do
      post microposts_path, micropost: { content: "Teh Rails logo", picture: picture }
    end
    assert assigns(:micropost).picture? 
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
    # Delete a Micropost
    assert_select 'a', text: 'delete'
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end
    # Visit a different user
    get user_path(users(:scully))
    assert_select 'a', text: 'delete', count: 0
    # Try to delete another users post
    assert_no_difference 'Micropost.count' do
      delete micropost_path(microposts(:van))
    end
  end

  test "micropost sidebar count" do
    log_in_as(@user)
    get root_path
    assert_match "#{@user.microposts.count} microposts", response.body
  end

  test "User with zero posts" do
    log_in_as(@other_user)
    assert @other_user.microposts.empty?, "user should not have any posts"
    get root_path
    assert_template 'static_pages/home'
    assert_match "0 microposts", response.body
    @other_user.microposts.create!(content: "bumpus jones best ever.")
    get root_path
    assert_match "1 micropost", response.body
  end
end
