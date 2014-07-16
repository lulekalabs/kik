class UpdateReviewsModifyStatus < ActiveRecord::Migration
  def self.up
    change_column :reviews, :status, :string, :default => "created", :null => false
  end

  def self.down
  end
end
