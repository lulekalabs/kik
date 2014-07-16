class UpdateKasesWithRegionCode < ActiveRecord::Migration
  def self.up
    add_column :kases, :province_code, :string
    add_index :kases, :province_code
  end

  def self.down
    remove_column :kases, :province_code
  end
end
