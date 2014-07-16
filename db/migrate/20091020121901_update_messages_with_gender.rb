# 20091020121901_update_messages_with_gender.rb
class UpdateMessagesWithGender < ActiveRecord::Migration
  def self.up
    add_column :messages, :sender_gender, :string, :limit => 1
    add_column :messages, :receiver_gender, :string, :limit => 1
  end

  def self.down
    remove_column :messages, :sender_gender
    remove_column :messages, :receiver_gender
  end
end
