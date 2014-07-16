class UpdateInvoicesWithConsecutiveNumbers < ActiveRecord::Migration
  def self.up
    add_column :invoices, :month_number, :integer
  end

  def self.down
    remove_column :invoices, :month_number
  end
end
