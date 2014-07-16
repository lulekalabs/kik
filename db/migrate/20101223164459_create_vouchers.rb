class CreateVouchers < ActiveRecord::Migration
  def self.up
    create_table "vouchers" do |t|
      t.integer  "consignor_id"
      t.integer  "consignee_id"
      t.integer  "promotable_id"
      t.string   "promotable_type"
      t.string   "promotable_sku"
      t.string   "code"
      t.string   "uuid"
      t.string   "uuid_base"
      t.string   "email"
      t.string   "timestamp"
      t.integer  "batch"
      t.string   "mac_address"
      t.datetime "created_at"
      t.datetime "expires_at"
      t.datetime "redeemed_at"
      t.integer  "cents", :default => 0, :null => false
      t.string   "currency", :limit => 3, :default => "USD", :null => false
      t.string   "type"
      t.integer  "amount", :default => 1, :null => false
    end

    add_index "vouchers", ["code"], :name => "index_vouchers_on_code"
    add_index "vouchers", ["consignee_id"], :name => "index_vouchers_on_consignee_id"
    add_index "vouchers", ["consignor_id"], :name => "index_vouchers_on_consignor_id"
    add_index "vouchers", ["email"], :name => "index_vouchers_on_email"
    add_index "vouchers", ["promotable_id", "promotable_type"], :name => "fk_vouchers_promotable"
    add_index "vouchers", ["type"], :name => "index_vouchers_on_type"
    add_index "vouchers", ["uuid"], :name => "index_vouchers_on_uuid"
  end

  def self.down
    drop_table "vouchers"
  end
end
