class UpdatePaymentsWithUuid < ActiveRecord::Migration
  def self.up
    add_column :payments, :uuid, :string
    add_index :payments, :uuid
  end

  def self.down
    remove_column :payments, :uuid
  end
end
