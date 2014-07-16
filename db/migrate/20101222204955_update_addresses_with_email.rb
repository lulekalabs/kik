class UpdateAddressesWithEmail < ActiveRecord::Migration
  def self.up
    add_column :addresses, :email, :string
    add_index :addresses, :email
  end

  def self.down
    remove_column :addresses, :email
  end
end
