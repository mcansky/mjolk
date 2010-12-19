require 'test_helper'

class BookmarkTest < ActiveSupport::TestCase
  should belong_to(:link)
  should belong_to(:user)
  should validate_presence_of(:link)
  should_validate_presence_of(:title)
  should_validate_presence_of(:user)
end
