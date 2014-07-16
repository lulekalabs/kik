class UpdateContactTransactionsWithOrder < ActiveRecord::Migration
  def self.up
    add_column :contact_transactions, :order_id, :integer
    add_index :contact_transactions, :order_id
  end

  def self.down
    remove_column :contact_transactions, :order_id
  end
end
