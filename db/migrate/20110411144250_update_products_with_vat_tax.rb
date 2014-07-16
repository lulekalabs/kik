class UpdateProductsWithVatTax < ActiveRecord::Migration
  def self.up
    add_column :products, :tax_rate, :float, :default => 19.0, :null => false
  end

  def self.down
    remove_column :products, :tax_rate
  end
end
