class CreateAccesses < ActiveRecord::Migration
  def self.up
    create_table :accesses, :id => false do |t|
      t.integer :requestor_id 
      t.integer :requestee_id 
      t.integer :accessible_id
      t.timestamps
    end
    add_index :accesses, :requestor_id
    add_index :accesses, :requestee_id
    add_index :accesses, :accessible_id
  end

  def self.down
    drop_table :accesses
  end
end
