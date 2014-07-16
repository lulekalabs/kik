class CreateVoucherRedemptions < ActiveRecord::Migration
  def self.up
    create_table :voucher_redemptions do |t|
      t.integer :voucher_id
      t.integer :person_id
      t.datetime :redeemed_at
      t.timestamps
    end
    add_index :voucher_redemptions, :voucher_id
    add_index :voucher_redemptions, :person_id
  end

  def self.down
    drop_table :voucher_redemptions
  end
end
