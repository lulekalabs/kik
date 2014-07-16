# 20091026194222_create_articles.rb
class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.column :person_id, :integer
      t.column :body, :text
      t.column :title, :string
      t.column :type, :string
      t.column :status, :string, :default => "created"
      t.column :published_at, :datetime
      t.column :deleted_at, :datetime
      t.timestamps
    end
    
    add_index :articles, :person_id
    add_index :articles, :title
    add_index :articles, :status
    add_index :articles, :type
  end

  def self.down
    drop_table :articles
  end
end
