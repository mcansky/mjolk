class TagsController < ApplicationController
  def index
    @tags = Bookmark.tag_counts_on(:tags)
  end
end
