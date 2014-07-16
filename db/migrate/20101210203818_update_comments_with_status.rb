class UpdateCommentsWithStatus < ActiveRecord::Migration
  def self.up
    add_column :comments, :status, :string, :default => 'created', :null => false
    add_index :comments, :status
  end

  def self.down
    remove_column :comments, :status
  end
end
