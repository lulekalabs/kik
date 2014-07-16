class UpdateTopicsWithTopicOnly < ActiveRecord::Migration
  def self.up
    add_column :topics, :topic_only, :boolean, :default => false, :null => false
    add_index :topics, :topic_only
  end

  def self.down
    remove_column :topics, :topic_only
  end
end
