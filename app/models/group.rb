class Group < ActiveRecord::Base
  validates_uniqueness_of :name, :case_sensitive => true
  has_and_belongs_to_many :users
  belongs_to :owner, :class_name => "User", :foreign_key => "owner_id"
  has_many :bookmarks, :through => :users, :conditions => ["private = 0"]

  def users_id
    ids = Array.new
    users.each { |u| ids << u.id }
    return ids
  end
end