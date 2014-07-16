class CreateResponses < ActiveRecord::Migration
  def self.up
    create_table :responses do |t|
      t.integer  "kase_id"
      t.integer  "person_id"
      t.text     "description"
      t.string   "status", :default => "created", :null => false
      t.timestamps
    end
    add_index :responses, :kase_id
    add_index :responses, :person_id
    add_index :responses, :status
  end

  def self.down
    drop_table :responses
  end
end
