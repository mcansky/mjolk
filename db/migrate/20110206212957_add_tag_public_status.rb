class AddTagPublicStatus < ActiveRecord::Migration
  def self.up
    add_column :taggings, :private, :boolean, :default => false
  end

  def self.down
    remove_column :taggings, :private
  end
end
