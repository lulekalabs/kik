class CreateTableArticlesTopics < ActiveRecord::Migration
  def self.up
    create_table :articles_topics, :id => false do |t|
      t.integer  :article_id
      t.integer  :topic_id
    end
    add_index :articles_topics, [:article_id, :topic_id]
  end

  def self.down
    drop_table :articles_topics
  end
end
