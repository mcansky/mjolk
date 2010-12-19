require 'test_helper'

class LinkTest < ActiveSupport::TestCase
  should have_many(:bookmarks)
  should have_many(:users).through(:bookmarks)
  should validate_presence_of(:url)
  should validate_uniqueness_of(:url)
end
