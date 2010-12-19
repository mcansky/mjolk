require 'test_helper'

class UserTest < ActiveSupport::TestCase
  should validate_uniqueness_of(:email)
  should ensure_length_of(:password).is_at_least(8)
  should ensure_length_of(:password).is_at_least(20)
  should have_many(:bookmarks)
  should have_many(:links).through(:bookmarks)
end
