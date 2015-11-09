require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = "      "
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = "      "
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                        first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                        foo@bar_baz.com foo@bar+baz.com user@example..com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  test "email addresses should be saved as lower-case" do
    mixed_case_email = "fOObaR@fOobAR.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end

  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Raw Freegan is the way to go.")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test "should follow and unfollow a user" do
    brett = users(:brett)
    skinner = users(:skinner)
    assert_not brett.following?(skinner)
    brett.follow(skinner)
    assert brett.following?(skinner)
    assert skinner.followers.include?(brett)
    brett.unfollow(skinner)
    assert_not brett.following?(skinner)
    assert_not skinner.followers.include?(brett)
  end

  test "feed should have the right posts" do
    brett = users(:brett) # Brett is the user whose feed is being tested
    fox = users(:fox) # Brett is following Fox
    skinner = users(:skinner) # Brett is not following Skinner
    # Posts from followed user
    fox.microposts.each do |post_following|
      assert brett.feed.include?(post_following)
    end
    # Posts from unfollowed user
    skinner.microposts.each do |post_unfollowed|
      assert brett.feed.include?(post_unfollowed)
    end
    # Posts from self
    brett.microposts.each do |post_self|
      assert brett.feed.include? (post_self)
    end
  end
end
