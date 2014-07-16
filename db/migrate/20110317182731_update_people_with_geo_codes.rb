class UpdatePeopleWithGeoCodes < ActiveRecord::Migration
  def self.up
    add_column :people, :province_code, :string
    add_column :people, :lat, :float
    add_column :people, :lng, :float
    
    add_index :people, :province_code
    add_index :people, [:lat, :lng]
  end

  def self.down
    remove_column :people, :province_code
    remove_column :people, :lat
    remove_column :people, :lng
  end
end
