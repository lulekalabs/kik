# 20091020122824_update_messages_with_subject.rb
class UpdateMessagesWithSubject < ActiveRecord::Migration
  def self.up
    add_column :messages, :subject, :string
    add_index :messages, :subject
  end

  def self.down
    remove_column :messages, :subject
  end
end
