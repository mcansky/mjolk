require 'digest/md5'

class Bookmark < ActiveRecord::Base
  belongs_to :link
  belongs_to :user
  validates_associated :link
  validates_presence_of :link
  validates_presence_of :title
  validates_presence_of :user
  before_save :update_meta
  # tags
  acts_as_taggable

  def update_meta
    self.meta = Digest::MD5.hexdigest(title + link.url + tags.join(' '))
  end

  def url
    return link.url
  end

  def date_to_s
    return bookmarked_at.strftime("%d.%m.%Y")
  end

  def private?
    return true if self.private == 1
    return false
  end
end
