class UpdateReviewAddTimestamps < ActiveRecord::Migration
  def self.up
    add_column :reviews, :preapproved_at, :datetime
    add_column :reviews, :opened_at, :datetime
    add_column :reviews, :closed_at, :datetime
    add_index :reviews, :opened_at
    add_index :reviews, :closed_at
  end

  def self.down
    remove_column :reviews, :preapproved_at
    remove_column :reviews, :opened_at
    remove_column :reviews, :closed_at
  end
end
