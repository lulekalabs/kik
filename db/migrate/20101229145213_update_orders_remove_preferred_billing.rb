class UpdateOrdersRemovePreferredBilling < ActiveRecord::Migration
  def self.up
    remove_column :orders, :preferred_billing_method
  end

  def self.down
    add_column :orders, :preferred_billing_method, :string
  end
end
