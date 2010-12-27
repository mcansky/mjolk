class AddUsersRoles < ActiveRecord::Migration
  def self.up
    add_column :users, :roles, :string
    add_column :users, :import_xml, :string
    add_column :users, :export_xml, :string
  end

  def self.down
    remove_column :users, :roles
    remove_column :users, :import_xml
    remove_column :users, :export_xml
  end
end
