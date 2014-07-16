class CreateSearchFiltersTopics < ActiveRecord::Migration
  def self.up
    create_table :search_filters_topics, :id => false do |t|
      t.integer  :search_filter_id
      t.integer  :topic_id
    end
    add_index :search_filters_topics, [:search_filter_id, :topic_id]
  end

  def self.down
    drop_table :search_filters_topics
  end
end
