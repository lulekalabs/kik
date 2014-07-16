class UpdatePeopleRenameAuthor < ActiveRecord::Migration
  def self.up
    rename_column :people, :author, :publisher
  end

  def self.down
    rename_column :people, :publisher, :author
  end
end
