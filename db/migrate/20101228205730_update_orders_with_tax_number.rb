class UpdateOrdersWithTaxNumber < ActiveRecord::Migration
  def self.up
    add_column :orders, :tax_number, :string
  end

  def self.down
    remove_column :orders, :tax_number
  end
end
