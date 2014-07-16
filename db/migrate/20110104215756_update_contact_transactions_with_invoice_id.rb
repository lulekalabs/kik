class UpdateContactTransactionsWithInvoiceId < ActiveRecord::Migration
  def self.up
    add_column :contact_transactions, :invoice_id, :integer
    add_index :contact_transactions, :invoice_id
  end

  def self.down
    remove_column :contact_transactions, :invoice_id
  end
end
