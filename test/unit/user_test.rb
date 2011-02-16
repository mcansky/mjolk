require 'test_helper'

class UserTest < ActiveSupport::TestCase
  subject { Factory(:user) }
  should validate_uniqueness_of(:email)
  should validate_presence_of(:email)
  should validate_presence_of(:password)
  should_not allow_value("abc").for(:password)
  should_not allow_value("123a").for(:password)
  should_not allow_value("1aaeca3a").for(:password)
  should allow_value("abzef2Da").for(:password)
  should allow_value("zef2dez%C").for(:password)
  should allow_value("dezfz%Acze").for(:password)
  should ensure_length_of(:password).is_at_least(8)
  should ensure_length_of(:password).is_at_most(20)
  should validate_uniqueness_of(:name)
  should_not allow_value(nil).for(:name)
  #should validate_presence_of(:name)
  should_not allow_value("admin").for(:name)
  should_not allow_value("login").for(:name)
  should_not allow_value("logout").for(:name)
  should have_many(:bookmarks)
  should have_many(:links).through(:bookmarks)
end
