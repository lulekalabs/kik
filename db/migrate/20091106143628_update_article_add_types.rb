# 20091106143628_update_article_add_types.rb
class UpdateArticleAddTypes < ActiveRecord::Migration
  def self.up
    rename_column :articles, :press, :press_release

    add_column :articles, :press_review, :boolean, :default => false
    add_index :articles, :press_review
    
    add_column :articles, :article, :boolean, :default => false
    add_index :articles, :article
    
    add_column :articles, :faq, :boolean, :default => false
    add_index :articles, :faq
  end

  def self.down
    rename_column :articles, :press_release, :press
    
    remove_column :articles, :press_review
    remove_column :articles, :article
    remove_column :articles, :faq
  end
end
