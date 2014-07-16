class UpdatePaymentsWithBankPaypalPaymentData < ActiveRecord::Migration
  def self.up
    add_column :payments, :bank_account_owner_name, :string
    add_column :payments, :bank_account_number, :string
    add_column :payments, :bank_routing_number, :string
    add_column :payments, :bank_name, :string
    add_column :payments, :bank_location, :string
    add_column :payments, :paypal_account, :string
  end

  def self.down
    remove_column :payments, :bank_account_owner_name
    remove_column :payments, :bank_account_number
    remove_column :payments, :bank_routing_number
    remove_column :payments, :bank_name
    remove_column :payments, :bank_location
    remove_column :payments, :paypal_account
  end
end
