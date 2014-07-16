class UpdateOrdersWithPreferredBillingMethod < ActiveRecord::Migration
  def self.up
    add_column :orders, :preferred_billing_method, :string
  end

  def self.down
    remove_column :orders, :preferred_billing_method
  end
end
