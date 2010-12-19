class Link < ActiveRecord::Base
  has_many :bookmarks
  has_many :users, :through => :bookmarks
  validates_presence_of :url
  validates_uniqueness_of :url, :case_sensitive => true
end
