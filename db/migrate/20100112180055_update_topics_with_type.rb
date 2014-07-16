class UpdateTopicsWithType < ActiveRecord::Migration
  def self.up
    add_column :topics, :type, :string
    add_index :topics, :type
  end

  def self.down
    remove_column :topics, :type
  end
end
