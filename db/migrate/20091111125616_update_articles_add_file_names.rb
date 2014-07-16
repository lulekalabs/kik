class UpdateArticlesAddFileNames < ActiveRecord::Migration
  def self.up
    add_column :articles, :primary_attachment_name, :string
    add_column :articles, :secondary_attachment_name, :string
  end

  def self.down
    remove_column :articles, :primary_attachment_name
    remove_column :articles, :secondary_attachment_name
  end
end
