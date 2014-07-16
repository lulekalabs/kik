# 20091005145224
class CreateAdminUsers < ActiveRecord::Migration
  def self.up

    create_table :admin_users do |t|
      t.string   :login
      t.string   :email
      t.string   :crypted_password, :limit => 40
      t.string   :salt, :limit => 40
      t.datetime :created_at
      t.datetime :updated_at
      t.string   :remember_token
      t.datetime :remember_token_expires_at
      t.string   :activation_code, :limit => 40
      t.datetime :activated_at
      t.string   :state, :default => "passive"
      t.datetime :deleted_at
    end
    add_index :admin_users, :login
    add_index :admin_users, :email
    
  end

  def self.down
    drop_table :admin_users
  end
end
