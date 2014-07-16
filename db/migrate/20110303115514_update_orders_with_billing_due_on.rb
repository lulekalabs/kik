class UpdateOrdersWithBillingDueOn < ActiveRecord::Migration
  def self.up
    add_column :orders, :billing_due_on, :date
    add_index :orders, :billing_due_on
  end

  def self.down
    remove_column :orders, :billing_due_on
  end
end
