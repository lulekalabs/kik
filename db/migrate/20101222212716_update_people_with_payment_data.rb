class UpdatePeopleWithPaymentData < ActiveRecord::Migration
  def self.up
    add_column :people, :preferred_payment_method, :string
    add_column :people, :paypal_account, :string
    add_column :people, :bank_account_owner_name, :string
    add_column :people, :bank_account_number, :string
    add_column :people, :bank_routing_number, :string
    add_column :people, :bank_name, :string
    add_column :people, :bank_location, :string

    add_column :people, :preferred_billing_method, :string
    add_column :people, :tax_number, :string
  end

  def self.down
    remove_column :people, :preferred_payment_method
    remove_column :people, :paypal_account
    remove_column :people, :bank_account_owner_name
    remove_column :people, :bank_account_number
    remove_column :people, :bank_routing_number
    remove_column :people, :bank_name
    remove_column :people, :bank_location

    remove_column :people, :preferred_billing_method
    remove_column :people, :tax_number
  end
end
