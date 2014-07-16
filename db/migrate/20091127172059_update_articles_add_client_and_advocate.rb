class UpdateArticlesAddClientAndAdvocate < ActiveRecord::Migration
  def self.up
    add_column :articles, :client_view, :boolean, :default => false
    add_column :articles, :advocate_view, :boolean, :default => false
    
    add_index :articles, :client_view
    add_index :articles, :advocate_view
  end

  def self.down
    remove_column :articles, :client_view
    remove_column :articles, :advocate_view
  end
end
