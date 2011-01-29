class TagsController < ApplicationController
  protect_from_forgery

  def index
    @tags = Bookmark.tag_counts_on(:tags)
  end
end
