class UpdateProductsWithTermDays < ActiveRecord::Migration
  def self.up
    add_column :products, :term_in_days, :integer
  end

  def self.down
    remove_column :products, :term_in_days
  end
end
