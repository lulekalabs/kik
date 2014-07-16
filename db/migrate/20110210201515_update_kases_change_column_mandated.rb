class UpdateKasesChangeColumnMandated < ActiveRecord::Migration
  def self.up
    change_column :kases, :mandated, :string
  end

  def self.down
    change_column :kases, :mandated, :boolean, :default => false, :null => false
  end
end
