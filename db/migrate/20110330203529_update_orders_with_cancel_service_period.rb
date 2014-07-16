class UpdateOrdersWithCancelServicePeriod < ActiveRecord::Migration
  def self.up
    add_column :orders, :cancel_on_service_period_end, :boolean, :default => false, :null => false
    add_index :orders, :cancel_on_service_period_end
  end

  def self.down
    remove_column :orders, :cancel_on_service_period_end
  end
end
