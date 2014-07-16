class UpdatePeopleWithContactsCount < ActiveRecord::Migration
  def self.up
    add_column :people, :premium_contacts_count, :integer, :null => false, :default => 0
    add_column :people, :promotion_contacts_count, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :people, :premium_contacts_count
    remove_column :people, :promotion_contacts_count
  end
end
