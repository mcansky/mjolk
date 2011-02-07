class TagsController < ApplicationController
  protect_from_forgery

  def index
    if params[:username]
      @user = User.find_by_name(params[:username])
      @tags = @user.bookmarks.tag_counts_on(:tags)
    else
      @tags = Bookmark.tag_counts_on(:tags)
    end
  end
end
