class UpdateProductsAddingSubscription < ActiveRecord::Migration
  def self.up
    add_column :products, :length_in_issues, :integer, :default => 0, :null => false
  end

  def self.down
    remove_column :products, :length_in_issues
  end
end
