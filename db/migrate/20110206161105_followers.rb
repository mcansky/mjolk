class Followers < ActiveRecord::Migration
  def self.up
    create_table :users_have_followers, :id => false do |t|
      t.integer :follower_id
      t.integer :followed_id
    end
  end
 
  def self.down
    drop_table :users_have_followers
  end
end
