class PersonAdvocateStores < ActiveRecord::Migration
  def self.up
    create_table :memorizes, :force => true do |t|
      t.integer :person_id, :advocate_id
      t.timestamps
    end
  end

  def self.down
    drop_table :memorizes
  end
end