class AddNewPropertiesInPeople < ActiveRecord::Migration
  def self.up
    change_table :people do |t|
      t.string :register_name, :register_number 
    end
  end

  def self.down
    change_table :people do |t|
      t.remove :register_number , :register_name
    end
  end
end