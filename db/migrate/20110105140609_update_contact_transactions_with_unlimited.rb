class UpdateContactTransactionsWithUnlimited < ActiveRecord::Migration
  def self.up
    add_column :contact_transactions, :flat, :boolean, :default => false, :null => false
    add_index :contact_transactions, :flat
  end

  def self.down
    remove_column :contact_transactions, :flat
  end
end
