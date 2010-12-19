class NewAttributes < ActiveRecord::Migration
  def self.up
    add_column :users, :bookmarks_update_at, :datetime
    add_column :bookmarks, :bookmarked_at, :datetime
  end

  def self.down
    remove_column :users, :bookmarks_update_at
    remove_column :bookmarks, :bookmarked_at
  end
end
