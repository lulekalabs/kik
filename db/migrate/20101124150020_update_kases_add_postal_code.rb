class UpdateKasesAddPostalCode < ActiveRecord::Migration
  def self.up
    add_column :kases, :postal_code, :string, :limit => 5
    add_index :kases, :postal_code
  end

  def self.down
    remove_column :kases, :postal_code
  end
end
