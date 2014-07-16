class UpdateKasesAddExpiresAt < ActiveRecord::Migration
  def self.up
    add_column :kases, :expires_at, :datetime
    add_index :kases, :expires_at
  end

  def self.down
    remove_column :kases, :expires_at
  end
end
