# 20091009114839_create_messages.rb
class CreateMessages < ActiveRecord::Migration
  
  def self.up
    create_table :messages do |t|
      t.string   "type"
      t.integer  "sender_id"
      t.integer  "receiver_id"
      t.string   "sender_first_name"
      t.string   "sender_last_name"
      t.string   "sender_email"
      t.string   "receiver_first_name"
      t.string   "receiver_last_name"
      t.string   "receiver_email"
      t.text     "message"
      t.string   "uuid"
      t.string   "status", :default => "queued", :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "sent_at"
      t.datetime "reminded_at"
      t.integer  "parent_id"
      t.string   "activation_code", :limit => 40
      t.datetime "accepted_at"
      t.datetime "declined_at"
      t.datetime "deleted_at"
    end

    add_index :messages, "type"
    add_index :messages, "sender_id"
    add_index :messages, "receiver_id"
    add_index :messages, "sender_first_name"
    add_index :messages, "sender_last_name"
    add_index :messages, "sender_email"
    add_index :messages, "receiver_first_name"
    add_index :messages, "receiver_last_name"
    add_index :messages, "receiver_email"
    add_index :messages, "parent_id"
    add_index :messages, "uuid"
    add_index :messages, "status"
    add_index :messages, "sent_at"
    add_index :messages, "reminded_at"
    add_index :messages, "activation_code"
  end

  def self.down
    drop_table :messages
  end
end
