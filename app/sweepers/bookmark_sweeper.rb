class BookmarkSweeper < ActionController::Caching::Sweeper
  observe Bookmark
  # If our sweeper detects that a Bookmark was created call this
  def after_create(bookmark)
    expire_fragment(%r{.*post.*})
    expire_cache_for(bookmark)
  end

  # If our sweeper detects that a Bookmark was updated call this
  def after_update(bookmark)
    expire_fragment(%r{.*post.*})
    expire_cache_for(bookmark)
  end

  # If our sweeper detects that a Bookmark was deleted call this
  def after_destroy(bookmark)
    expire_fragment(%r{.*post.*})
    expire_cache_for(bookmark)
  end

  private
  def expire_cache_for(bookmark)
    # Expire the index page now that we added a new bookmark
    expire_page(:controller => 'posts', :action => 'index')

    # Expire a fragment
    expire_fragment('all_available_bookmarks')
    expire_fragment('all_user_#{curren_user.id}_posts')
    expire_fragment('all_tags')
    expire_fragment("tags_#{current_user.name}")
    expire_fragment('last_20_posts')
    expire_fragment('public_all_posts')
    expire_fragment('public_last_20_posts')
  end
end