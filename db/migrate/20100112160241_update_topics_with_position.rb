class UpdateTopicsWithPosition < ActiveRecord::Migration
  def self.up
    add_column :topics, :position, :integer
    add_index :topics, :position
  end

  def self.down
    remove_column :topics, :position
  end
end
