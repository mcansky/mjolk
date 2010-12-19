class NewAttributes < ActiveRecord::Migration
  def self.up
    add_column :users, :bookmarks_update_at, :datetime
    add_column :bookmarks, :bookmarked_at, :datetime
    add_column :bookmarks, :meta, :string
    add_column :bookmarks, :private, :boolean, :default => false
  end

  def self.down
    remove_column :users, :bookmarks_update_at
    remove_column :bookmarks, :bookmarked_at
    remove_column :bookmarks, :meta
    remove_column :bookmarks, :private
  end
end
