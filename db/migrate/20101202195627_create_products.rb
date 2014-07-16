class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.string   "name"
      t.string   "description"
      t.integer  "cents", :default => 0, :null => false
      t.string   "currency", :limit => 3, :default => "EUR", :null => false
      t.string   "sku"
      t.integer  "contacts"
      t.integer  "position"
      t.boolean  "active", :default => true,  :null => false
      t.boolean  "subscription", :default => false,  :null => false
      t.timestamps
    end
    add_index :products, :name
    add_index :products, [:cents, :currency]
    add_index :products, :sku
    add_index :products, :position
    add_index :products, :active
    add_index :products, :subscription
    add_index :products, :contacts
  end

  def self.down
    drop_table :products
  end
end
