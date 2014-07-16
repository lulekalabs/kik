# 20091002181126
class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string   :login
      t.string   :crypted_password, :limit => 40
      t.string   :salt, :limit => 40
      t.string   :remember_token
      t.string   :activation_code, :limit => 40
      t.string   :state, :default => "passive"
      t.boolean  :persist, :default => true
      t.integer  :person_id
      t.datetime :deleted_at
      t.datetime :activated_at
      t.datetime :remember_token_expires_at
      t.datetime :created_at
      t.datetime :updated_at
    end
    
    add_index :users, :person_id
  end

  def self.down
    drop_table :users
  end
end
