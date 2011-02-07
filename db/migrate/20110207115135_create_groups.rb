class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.string :name
      t.text :desc
      t.integer :owner_id
      t.timestamps
    end
    create_table :groups_users, :id => false do |t|
      t.integer :user_id
      t.integer :group_id
    end
  end

  def self.down
    drop_table :groups
    drop_table :groups_users
  end
end
