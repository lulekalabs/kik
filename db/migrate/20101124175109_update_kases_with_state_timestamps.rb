class UpdateKasesWithStateTimestamps < ActiveRecord::Migration
  def self.up
    add_column :kases, :preapproved_at, :datetime
    add_column :kases, :opened_at, :datetime
    add_column :kases, :closed_at, :datetime
    add_index :kases, :preapproved_at
    add_index :kases, :opened_at
    add_index :kases, :closed_at
  end

  def self.down
    remove_column :kases, :preapproved_at
    remove_column :kases, :opened_at
    remove_column :kases, :closed_at
  end
end
