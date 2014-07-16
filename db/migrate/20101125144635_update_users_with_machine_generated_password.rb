class UpdateUsersWithMachineGeneratedPassword < ActiveRecord::Migration
  def self.up
    add_column :users, :password_is_generated, :boolean, :null => false, :default => false
    add_index :users, :password_is_generated
  end

  def self.down
    remove_column :users, :password_is_generated
  end
end
