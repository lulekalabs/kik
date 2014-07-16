class CreateMerchantSidekickTables < ActiveRecord::Migration
  def self.up
    #--- gateways
    create_table "gateways", :force => true do |t|
      t.string "name",            :null => false
      t.string "mode"
      t.string "type"
      t.string "login_id"
      t.string "transaction_key"
    end
    add_index "gateways", ["name"], :name => "index_gateways_on_name"
    add_index "gateways", ["type"], :name => "index_gateways_on_type"
    
    #--- invoices
    create_table "invoices", :force => true do |t|
      t.integer  "buyer_id"
      t.string   "buyer_type"
      t.integer  "seller_id"
      t.string   "seller_type"
      t.integer  "net_cents",    :default => 0,         :null => false
      t.integer  "tax_cents",    :default => 0,         :null => false
      t.integer  "gross_cents",  :default => 0,         :null => false
      t.float    "tax_rate",     :default => 0.0,       :null => false
      t.string   "currency",     :default => "USD",     :null => false
      t.string   "type"
      t.string   "number"
      t.boolean  "lock_version", :default => false,     :null => false
      t.string   "status",       :default => "pending", :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "paid_at"
    end
    add_index "invoices", ["buyer_id", "buyer_type"], :name => "index_invoices_on_buyer_id_and_buyer_type"
    add_index "invoices", ["number"], :name => "index_invoices_on_number"
    add_index "invoices", ["seller_id", "seller_type"], :name => "index_invoices_on_seller_id_and_seller_type"
    add_index "invoices", ["type"], :name => "index_invoices_on_type"

    #--- cart line items
    create_table "cart_line_items", :force => true do |t|
      t.string   "item_number"
      t.string   "name"
      t.string   "description"
      t.integer  "quantity",                  :default => 1,       :null => false
      t.string   "unit",                      :default => "piece", :null => false
      t.integer  "pieces",                    :default => 0,       :null => false
      t.integer  "cents",                     :default => 0,       :null => false
      t.string   "currency",     :limit => 3, :default => "USD",   :null => false
      t.boolean  "taxable",                   :default => false,   :null => false
      t.integer  "product_id",                                     :null => false
      t.string   "product_type",                                   :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_index "cart_line_items", ["description"], :name => "index_cart_line_items_on_description"
    add_index "cart_line_items", ["item_number"], :name => "index_cart_line_items_on_item_number"
    add_index "cart_line_items", ["name"], :name => "index_cart_line_items_on_name"
    add_index "cart_line_items", ["pieces"], :name => "index_cart_line_items_on_pieces"
    add_index "cart_line_items", ["product_id", "product_type"], :name => "index_cart_line_items_on_product_id_and_product_type"
    add_index "cart_line_items", ["quantity"], :name => "index_cart_line_items_on_quantity"
    add_index "cart_line_items", ["unit"], :name => "index_cart_line_items_on_unit"

    #--- line items
    create_table "line_items", :force => true do |t|
      t.integer "order_id"
      t.integer "invoice_id"
      t.integer "sellable_id"
      t.string  "sellable_type"
      t.integer "net_cents"
      t.string  "currency"
      t.integer "tax_cents",     :default => 0,   :null => false
      t.integer "gross_cents",   :default => 0,   :null => false
      t.float   "tax_rate",      :default => 0.0, :null => false
    end
    add_index "line_items", ["invoice_id"], :name => "index_line_items_on_invoice_id"
    add_index "line_items", ["order_id"], :name => "index_line_items_on_order_id"
    add_index "line_items", ["sellable_id", "sellable_type"], :name => "fk_line_items_sellable"

    #--- orders
    create_table "orders", :force => true do |t|
      t.integer  "buyer_id"
      t.string   "buyer_type"
      t.integer  "seller_id"
      t.string   "seller_type"
      t.integer  "invoice_id"
      t.integer  "net_cents",                 :default => 0,         :null => false
      t.integer  "tax_cents",                 :default => 0,         :null => false
      t.integer  "gross_cents",               :default => 0,         :null => false
      t.string   "currency",     :limit => 3, :default => "USD",     :null => false
      t.float    "tax_rate",                  :default => 0.0,       :null => false
      t.string   "type"
      t.boolean  "lock_version",              :default => false,     :null => false
      t.string   "status",                    :default => "created", :null => false
      t.string   "number"
      t.string   "description"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "canceled_at"
    end
    add_index "orders", ["buyer_id", "buyer_type"], :name => "index_orders_on_buyer_id_and_buyer_type"
    add_index "orders", ["seller_id", "seller_type"], :name => "index_orders_on_seller_id_and_seller_type"
    add_index "orders", ["status"], :name => "index_orders_on_status"
    add_index "orders", ["type"], :name => "index_orders_on_type"

    #--- payments
    create_table "payments", :force => true do |t|
      t.integer  "payable_id"
      t.string   "payable_type"
      t.boolean  "success"
      t.string   "reference"
      t.string   "message"
      t.string   "action"
      t.string   "params"
      t.boolean  "test"
      t.integer  "cents",                     :default => 0,     :null => false
      t.string   "currency",     :limit => 3, :default => "USD", :null => false
      t.integer  "lock_version",              :default => 0,     :null => false
      t.integer  "position"
      t.string   "type"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_index "payments", ["action"], :name => "index_payments_on_action"
    add_index "payments", ["message"], :name => "index_payments_on_message"
    add_index "payments", ["params"], :name => "index_payments_on_params"
    add_index "payments", ["payable_id", "payable_type"], :name => "index_payments_on_payable_id_and_payable_type"
    add_index "payments", ["position"], :name => "index_payments_on_position"
    add_index "payments", ["reference"], :name => "index_payments_on_reference"
    
  end

  def self.down
    drop_table "gateways"
    drop_table "invoices"  
    drop_table "cart_line_items"
    drop_table "line_items"
    drop_table "orders"
    drop_table "payments"
  end
end
