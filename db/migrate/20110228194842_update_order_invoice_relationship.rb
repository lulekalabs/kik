class UpdateOrderInvoiceRelationship < ActiveRecord::Migration
  def self.up
    add_column :invoices, :order_id, :integer
    add_index :invoices, :order_id
    
    execute "UPDATE invoices, orders SET invoices.order_id = orders.id " +
      "WHERE orders.invoice_id = invoices.id"
  end

  def self.down
    remove_column :invoices, :order_id
  end
end
