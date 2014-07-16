class UpdateProductsAddUnlimitedContacts < ActiveRecord::Migration
  def self.up
    add_column :products, :flat, :boolean, :default => false, :null => false
    add_index :products, :flat
  end

  def self.down
    remove_column :products, :flat
  end
end
