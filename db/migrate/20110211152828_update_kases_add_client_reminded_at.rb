class UpdateKasesAddClientRemindedAt < ActiveRecord::Migration
  def self.up
    add_column :kases, :client_reminded_at, :datetime
  end

  def self.down
    remove_column :kases, :client_reminded_at
  end
end
