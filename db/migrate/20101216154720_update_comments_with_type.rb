class UpdateCommentsWithType < ActiveRecord::Migration
  def self.up
    add_column :comments, :type, :string
    add_column :comments, :grade, :float
    add_index :comments, :type
  end

  def self.down
    remove_column :comments, :type
    remove_column :comments, :grade
  end
end
