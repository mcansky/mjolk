class Link < ActiveRecord::Base
  has_many :bookmarks
#  has_many :users, :through => bookmarks
end
