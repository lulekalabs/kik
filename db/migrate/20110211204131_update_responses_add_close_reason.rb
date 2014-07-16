class UpdateResponsesAddCloseReason < ActiveRecord::Migration
  def self.up
    add_column :responses, :close_reason, :string
    add_column :responses, :close_description, :string
  end

  def self.down
    remove_column :responses, :close_reason
    remove_column :responses, :close_description
  end
end
