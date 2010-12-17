class CreateBookmarks < ActiveRecord::Migration
  def self.up
    create_table :bookmarks do |t|
      t.string :title
      t.text :comment
      t.integer :link_id
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :bookmarks
  end
end
