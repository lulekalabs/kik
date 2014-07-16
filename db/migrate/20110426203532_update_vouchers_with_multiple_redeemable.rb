class UpdateVouchersWithMultipleRedeemable < ActiveRecord::Migration
  def self.up
    add_column :vouchers, :multiple_redeemable, :boolean, :null => false, :default => false
    add_index :vouchers, :multiple_redeemable
  end

  def self.down
    remove_column :vouchers, :multiple_redeemable
  end
end
