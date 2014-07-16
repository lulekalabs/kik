class AddMessageFlagInPerson < ActiveRecord::Migration
  def self.up
    change_table :people do |t|
      t.boolean :send_evaluate_message , :default => false
    end
  end

  def self.down
    change_table :people do |t|
      t.remove :send_evaluate_message
    end
  end
end