class UpdateKasesWithReferrer < ActiveRecord::Migration
  def self.up
    add_column :kases, :referrer, :string
    add_index :kases, :referrer
  end

  def self.down
    remove_column :kases, :referrer
  end
end
