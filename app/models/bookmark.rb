class Bookmark < ActiveRecord::Base
  belongs_to :link
  belongs_to :user
  validates_associated :link
  validates_presence_of :link
  validates_presence_of :title
  validates_associated :user
  validates_presence_of :user
end
