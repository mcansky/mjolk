class MoveToInt < ActiveRecord::Migration
  def self.up
    remove_column :bookmarks, :private
    add_column :bookmarks, :private, :integer, :default => 0
  end

  def self.down
    remove_column :bookmarks, :private
    add_column :bookmarks, :private, :boolean
  end
end
