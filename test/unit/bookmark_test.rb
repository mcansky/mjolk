require 'test_helper'

class BookmarkTest < ActiveSupport::TestCase
  should belong_to(:link)
  should belong_to(:user)
end
