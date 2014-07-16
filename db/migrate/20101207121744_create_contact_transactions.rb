class CreateContactTransactions < ActiveRecord::Migration
  def self.up
    create_table :contact_transactions do |t|
      t.integer :person_id
      t.integer :amount, :null => false, :default => 0
      t.datetime :expires_at
      t.string :type
      t.timestamps
    end
    add_index :contact_transactions, :person_id
  end

  def self.down
    drop_table :contact_transactions
  end
end
