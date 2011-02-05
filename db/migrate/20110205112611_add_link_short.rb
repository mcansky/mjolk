class AddLinkShort < ActiveRecord::Migration
  def self.up
    add_column :links, :short_url, :string
  end

  def self.down
    remove_column :links, :short_url
  end
end
