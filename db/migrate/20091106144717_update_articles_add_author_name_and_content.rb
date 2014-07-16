class UpdateArticlesAddAuthorNameAndContent < ActiveRecord::Migration
  def self.up
    add_column :articles, :author_name, :string
    add_index :articles, :author_name
    
    add_column :articles, :summary, :text
  end

  def self.down
    remove_column :articles, :author_name
    remove_column :articles, :summary
  end
end
