class UpdateKasesAddCloseReason < ActiveRecord::Migration
  def self.up
    add_column :kases, :close_reason, :string
  end

  def self.down
    remove_column :kases, :close_reason
  end
end
