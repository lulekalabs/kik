# 20091028123723_update_articles_with_categories
class UpdateArticlesWithCategories < ActiveRecord::Migration
  def self.up
    add_column :articles, :blog, :boolean, :default => false
    add_column :articles, :press, :boolean, :default => false
    add_column :articles, :dictionary, :boolean, :default => false
    
    add_index :articles, :blog
    add_index :articles, :press
    add_index :articles, :dictionary
  end

  def self.down
    remove_column :articles, :blog
    remove_column :articles, :press
    remove_column :articles, :dictionary
  end
end
