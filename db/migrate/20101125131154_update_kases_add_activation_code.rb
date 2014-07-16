class UpdateKasesAddActivationCode < ActiveRecord::Migration
  def self.up
    add_column :kases, :activation_code, :string
    add_index :kases, :activation_code
  end

  def self.down
    remove_column :kases, :activation_code
  end
end
