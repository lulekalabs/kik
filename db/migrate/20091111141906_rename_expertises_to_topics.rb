# 20091111141906_rename_expertises_to_topics.rb
class RenameExpertisesToTopics < ActiveRecord::Migration
  def self.up
    rename_table :expertises, :topics
    execute "UPDATE taggings SET taggings.taggable_type = 'Topic' WHERE taggings.taggable_type = 'Expertise'"
  end

  def self.down
    rename_table :topics, :expertises
    execute "UPDATE taggings SET taggings.taggable_type = 'Expertise' WHERE taggings.taggable_type = 'Topic'"
  end
end
