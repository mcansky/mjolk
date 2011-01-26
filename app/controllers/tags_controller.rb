class TagsController < ApplicationController
  def index
    @tags = Post.tag_counts_on(:tags)
  end
end
