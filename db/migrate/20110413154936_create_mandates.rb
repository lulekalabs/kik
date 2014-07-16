class CreateMandates < ActiveRecord::Migration
  def self.up
    create_table :mandates do |t|
      t.integer :client_id
      t.integer :advocate_id
      t.integer :kase_id
      t.integer :response_id
      t.string :type
      t.string :action
      t.timestamps
    end
    add_index :mandates, :client_id
    add_index :mandates, :advocate_id
    add_index :mandates, :kase_id
    add_index :mandates, :response_id
  end

  def self.down
    drop_table :mandates
  end
end
