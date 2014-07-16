class UpdateAdminUsersWithResetCode < ActiveRecord::Migration
  def self.up
    add_column :admin_users, :reset_code, :string
    add_index :admin_users, :reset_code
  end

  def self.down
    remove_column :admin_users, :reset_code
  end
end
