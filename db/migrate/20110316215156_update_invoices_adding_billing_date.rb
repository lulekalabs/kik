class UpdateInvoicesAddingBillingDate < ActiveRecord::Migration
  def self.up
    add_column :invoices, :billing_date_on, :date
    add_index :invoices, :billing_date_on
  end

  def self.down
    remove_column :invoices, :billing_date_on
  end
end
