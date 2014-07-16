class UpdateMandatesWithStatus < ActiveRecord::Migration
  def self.up
    add_column :mandates, :status, :string, :default => "created", :null => false
    add_index :mandates, :status
    
    add_column :mandates, :accepted_at, :datetime
    add_column :mandates, :declined_at, :datetime
  end

  def self.down
    remove_column :mandates, :status
    remove_column :mandates, :accepted_at
    remove_column :mandates, :declined_at
  end
end
