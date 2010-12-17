require 'test_helper'

class UserTest < ActiveSupport::TestCase
  should validate_uniqueness_of(:email)
  should have_many(:bookmarks)
  should have_many(:links).through(:bookmarks)
end
