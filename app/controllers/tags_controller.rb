class TagsController < ApplicationController
  authorize_resource

  def index
    @tags = Bookmark.tag_counts_on(:tags)
  end
end
