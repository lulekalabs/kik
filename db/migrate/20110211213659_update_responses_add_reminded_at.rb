class UpdateResponsesAddRemindedAt < ActiveRecord::Migration
  def self.up
    add_column :responses, :advocate_reminded_at, :datetime
    add_index :responses, :advocate_reminded_at
  end

  def self.down
    remove_column :responses, :advocate_reminded_at
  end
end
