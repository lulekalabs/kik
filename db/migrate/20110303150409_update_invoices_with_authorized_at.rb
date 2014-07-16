class UpdateInvoicesWithAuthorizedAt < ActiveRecord::Migration
  def self.up
    add_column :invoices, :authorized_at, :datetime
  end

  def self.down
    remove_column :invoices, :authorized_at
  end
end
