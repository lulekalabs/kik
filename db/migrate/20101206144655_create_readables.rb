class CreateReadables < ActiveRecord::Migration
  def self.up
    create_table :readings, :id => false do |t|
      t.string :readable_type
      t.integer :readable_id
      t.integer :person_id
      t.timestamps
    end
    add_index :readings, [:readable_id, :readable_type]
    add_index :readings, :person_id
  end

  def self.down
    drop_table :readings
  end
end
