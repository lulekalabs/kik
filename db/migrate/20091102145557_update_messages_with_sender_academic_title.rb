# 20091102145557_update_messages_with_sender_academic_title.rb
class UpdateMessagesWithSenderAcademicTitle < ActiveRecord::Migration
  def self.up
    add_column :messages, :sender_academic_title_id, :integer
    add_column :messages, :receiver_academic_title_id, :integer
  end

  def self.down
    remove_column :messages, :sender_academic_title_id
    remove_column :messages, :receiver_academic_title_id
  end
end
