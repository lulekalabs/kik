class UpdateMessagesAddIpAddress < ActiveRecord::Migration
  def self.up
    add_column :messages, :ip, :string
  end

  def self.down
    remove_column :messages, :ip
  end
end
