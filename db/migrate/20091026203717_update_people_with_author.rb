# 20091026203717_update_people_with_author.rb
class UpdatePeopleWithAuthor < ActiveRecord::Migration
  def self.up
    add_column :people, :author, :boolean, :default => false
    add_index :people, :author
  end

  def self.down
    remove_column :people, :author
  end
end
