class UpdateTopicsWithChangeDefault < ActiveRecord::Migration
  def self.up
    change_column :topics, :topic_only, :boolean, :default => true, :null => false
    change_column :topics, :expertise_only, :boolean, :default => true, :null => false
  end

  def self.down
    change_column :topics, :topic_only, :boolean, :default => false, :null => false
    change_column :topics, :expertise_only, :boolean, :default => false, :null => false
  end
end
