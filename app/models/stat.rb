class Stat < ActiveRecord::Base
  def generate
    self.users = User.all.count
    self.bookmarks = Bookmark.all.count
    self.tags = ActsAsTaggableOn::Tag.all.count
  end

  def data
    data = Hash.new
    data[:users] = [created_at.usec * 1000, users]
    data[:bookmarks] = [created_at.usec * 1000, bookmarks]
    data[:tags] = [created_at.usec * 1000, tags]
    return data
  end
end
