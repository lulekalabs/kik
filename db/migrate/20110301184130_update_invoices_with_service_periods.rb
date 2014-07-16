class UpdateInvoicesWithServicePeriods < ActiveRecord::Migration
  def self.up
    add_column :invoices, :service_period_start_on, :date
    add_column :invoices, :service_period_end_on, :date
    add_index :invoices, :service_period_start_on
    add_index :invoices, :service_period_end_on
  end

  def self.down
    remove_column :invoices, :service_period_start_on
    remove_column :invoices, :service_period_end_on
  end
end
