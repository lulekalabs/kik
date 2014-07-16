class UpdateArticlesAddAdvofinderAndKikViews < ActiveRecord::Migration
  def self.up
    add_column :articles, :kik_view, :boolean, :default => true
    add_column :articles, :advofinder_view, :boolean, :default => false
    
    add_index :articles, :kik_view
    add_index :articles, :advofinder_view
  end

  def self.down
    remove_column :articles, :kik_view
    remove_column :articles, :advofinder_view
  end
end
