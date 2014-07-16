class UpdateTopicsWithExpertiseOnly < ActiveRecord::Migration
  def self.up
    add_column :topics, :expertise_only, :boolean, :default => false
    add_index :topics, :expertise_only
  end

  def self.down
    remove_column :topics, :expertise_only
  end
end
