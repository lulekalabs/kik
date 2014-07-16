class UpdateContactTransactionWithFlex < ActiveRecord::Migration
  def self.up
    add_column :contact_transactions, :flex, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :contact_transactions, :flex
  end
end
