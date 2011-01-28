class CreateStats < ActiveRecord::Migration
  def self.up
    create_table :stats do |t|
      t.integer :users
      t.integer :bookmarks
      t.integer :tags

      t.timestamps
    end
  end

  def self.down
    drop_table :stats
  end
end
