require 'test_helper'

class LinkTest < ActiveSupport::TestCase
  should have_many(:bookmarks)
  should have_many(:users).through(:bookmarks)
end
