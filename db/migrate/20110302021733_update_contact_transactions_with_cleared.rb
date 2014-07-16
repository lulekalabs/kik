class UpdateContactTransactionsWithCleared < ActiveRecord::Migration
  def self.up
    add_column :contact_transactions, :cleared_at, :datetime
    add_index :contact_transactions, :cleared_at
  end

  def self.down
    remove_column :contact_transactions, :cleared_at
  end
end
