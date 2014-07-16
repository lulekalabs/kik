class UpdateContractTransactionWithStartAt < ActiveRecord::Migration
  def self.up
    add_column :contact_transactions, :start_at, :datetime
    add_index :contact_transactions, :start_at
  end

  def self.down
    remove_column :contact_transactions, :start_at
  end
end
